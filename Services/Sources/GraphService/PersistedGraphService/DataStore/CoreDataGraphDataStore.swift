//
// CoreDataGraphDataStore.swift
// 
//
// Created by Kamil Zaborowski on 13/07/2023
// Copyright © 2023 Kamil Zaborowski. All rights reserved.
//

import Foundation
import CoreData
import GraphMLParser

public class CoreDataGraphDataStore: GraphDataStore {
    private let context: NSManagedObjectContext
    private let backgroundContext: NSManagedObjectContext
    
    private var mergeError: Error?
    
    public convenience init(inMemory: Bool = false, conflictsPolicy: ConflictsPolicy = .throwError) {
        CodableValueTransformer<[GenericElement]>.register(name: "GenericElementTransformer")
        CodableValueTransformer<[String: String]>.register(name: "AttributesTransformer")
        
        let container = NSPersistentContainer(name: "GraphModel", bundle: Bundle.module)
        
        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        }
        
        container.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Failed to initialize CoreData: \(error)")
            }
        }
        self.init(context: container.viewContext, conflictsPolicy: conflictsPolicy)
    }
    
    init(context: NSManagedObjectContext, conflictsPolicy: ConflictsPolicy) {
        self.context = context
        context.undoManager = nil
        context.mergePolicy = NSMergePolicy(merge: conflictsPolicy.asMergePolicyType())
        
        backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.parent = context
        backgroundContext.automaticallyMergesChangesFromParent = false
        backgroundContext.mergePolicy = NSMergePolicy(merge: conflictsPolicy.asMergePolicyType())

        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSManagedObjectContextDidSave, object: backgroundContext, queue: nil) { [weak self] notification in
            
            context.performAndWait {
                context.mergeChanges(fromContextDidSave: notification)
                do {
                    try context.save()
                } catch {
                    self?.mergeError = error
                }
                context.reset()
            }
        }
    }
    
    public func saveGraph(graph: GraphDef) throws {
        try backgroundContext.performAndWait {
            let cdGraph = CDGraph(context: backgroundContext)
            cdGraph.id = graph.id
            cdGraph.directed = graph.directed
            
            try save(context: backgroundContext)
        }
    }
    
    public func saveNode(node: GraphNode, graphId: GraphDef.ID, batchSize: Int) throws {
        try backgroundContext.performAndWait {
            let cdNode = CDNode(context: backgroundContext)
            cdNode.id = node.id
            cdNode.graph = graphId
            cdNode.attributes = node.attributes
            cdNode.elements = node.elements as NSObject
            
            try save(context: backgroundContext, batchSize: batchSize)
        }
    }
    
    public func saveEdge(edge: GraphEdge, graphId: GraphDef.ID, batchSize: Int) throws {
        try backgroundContext.performAndWait {
            let cdEdge = CDEdge(context: backgroundContext)
            
            cdEdge.source = edge.source
            cdEdge.target = edge.target
            cdEdge.graph = graphId
            
            try save(context: backgroundContext, batchSize: batchSize)
        }
    }
    
    public func getGraphs(limit: Int?) async throws -> [GraphDef] {
        try await context.perform {
            let request = CDGraph.fetchRequest()
            
            if let limit {
                request.fetchLimit = limit
            }
            
            let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
            request.sortDescriptors = [sortDescriptor]
            
            let cdGraph = try self.context.fetch(request)
            return cdGraph.map({ $0.asGraph() })
        }
    }
    
    public func getGraph(id: GraphDef.ID) async throws -> GraphDef {
        try await context.perform {
            let cdGraph = try self.getCDGraph(id: id)
            return cdGraph.asGraph()
        }
    }
    
    public func getNodes(graphId: GraphDef.ID, limit: Int) async throws -> [GraphNode] {
        try await context.perform {
            let request = CDNode.fetchRequest()
            request.predicate = NSPredicate(format: "graph == %@", graphId)
            request.fetchLimit = limit
            
            let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
            request.sortDescriptors = [sortDescriptor]
            
            let cdNodes = try self.context.fetch(request)
            return cdNodes.map({ $0.asGraphNode() })
        }
    }
    
    public func getNode(id: GraphNode.ID, graphId: GraphDef.ID) async throws -> GraphNode {
        try await context.perform {
            let cdNode = try self.getCDNode(id: id, graphId: graphId)
            return cdNode.asGraphNode()
        }
    }
    
    public func getEdges(source: GraphNode.ID, graphId: GraphDef.ID) async throws -> [GraphEdge] {
        try await context.perform {
            let request = CDEdge.fetchRequest()
            request.predicate = NSPredicate(format: "source == %@ AND graph == %@", source, graphId)
            
            let cdEdges = try self.context.fetch(request)
            return cdEdges.map({ $0.asGraphEdge() })
        }
    }
    
    public func getEdges(target: GraphNode.ID, graphId: GraphDef.ID) async throws -> [GraphEdge] {
        try await context.perform {
            let request = CDEdge.fetchRequest()
            request.predicate = NSPredicate(format: "target == %@ AND graph == %@", target, graphId)
            
            let cdEdges = try self.context.fetch(request)
            return cdEdges.map({ $0.asGraphEdge() })
        }
    }
    
    public func saveIfNeeded() throws {
        try backgroundContext.performAndWait {
            guard backgroundContext.hasChanges else {
                return
            }
            try save(context: backgroundContext)
        }
    }
    
    // MARK: PRIVATE
    
    private func getCDGraph(id: GraphDef.ID) throws -> CDGraph {
        let request = CDGraph.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        
        let cdGraphs = try context.fetch(request)
        guard let cdGraph = cdGraphs.first else {
            throw CoreDataGraphDataStoreError.graphNotFound(id)
        }
        
        return cdGraph
    }
    
    private func getCDNode(id: GraphNode.ID, graphId: GraphDef.ID) throws -> CDNode {
        let request = CDNode.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@ AND graph == %@", id, graphId)
        
        let cdNodes = try context.fetch(request)
        guard let cdNode = cdNodes.first else {
            throw CoreDataGraphDataStoreError.nodeNotFound(nodeId: id, graphId: graphId)
        }
        
        return cdNode
    }
    
    private var saveCounter = 0
    private func save(context: NSManagedObjectContext, batchSize: Int = 0) throws {
        saveCounter += 1
        
        if batchSize > 0, saveCounter % batchSize != 0 {
            return
        }
        
        mergeError = nil
        
        do {
            try context.save()
        } catch {
            mergeError = error
        }
        
        context.reset()
        
        if let error = mergeError {
            throw error
        }
    }
}

extension CoreDataGraphDataStore {
    public enum ConflictsPolicy {
        case overwrite
        case throwError
        
        func asMergePolicyType() -> NSMergePolicyType {
            switch self {
            case .overwrite:
                return .overwriteMergePolicyType
            case .throwError:
                return .errorMergePolicyType
            }
        }
    }
}

extension CDGraph {
    func asGraph() -> GraphDef {
        GraphDef(id: id!, directed: directed)
    }
}

extension CDNode {
    func asGraphNode() -> GraphNode {
        let dAttributes = attributes ?? [:]
        let dElements = elements as? [GenericElement] ?? []
        
        return GraphNode(id: id!, attributes: dAttributes, elements: dElements)
    }
}

extension CDEdge {
    func asGraphEdge() -> GraphEdge {
        return GraphEdge(source: source!, target: target!)
    }
}

enum CoreDataGraphDataStoreError: LocalizedError {
    case graphNotFound(GraphDef.ID)
    case nodeNotFound(nodeId: GraphNode.ID, graphId: GraphDef.ID)
    
    var errorDescription: String? {
        switch self {
        case .graphNotFound(let id):
            return "Graph \(id) not found"
        case .nodeNotFound(let nodeId, let graphId):
            return "Node \(nodeId) for graph \(graphId) not found"
        }
    }
}
