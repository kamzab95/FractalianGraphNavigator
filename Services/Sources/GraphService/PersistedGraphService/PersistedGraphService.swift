//
// PersistedGraphService.swift
// 
//
// Created by Kamil Zaborowski on 12/07/2023
// Copyright © 2023 Kamil Zaborowski. All rights reserved.
//

import Foundation
import GraphMLParser
import CoreData

public class CoreDataGraphService: GraphService {
    
    private let dataStore: GraphDataStore
    private var graphMLParser: GraphParser?
    
    public init(dataStore: GraphDataStore) {
        self.dataStore = dataStore
    }
    
    public func loadGraph(url: URL, graphId: String) async throws {
        let processor = GraphProcessor(graphId: graphId, dataStore: dataStore)
        try processor.loadGraph(url: url)
    }
    
    public func getGraphs() async throws -> [GraphDef] {
        try await dataStore.getGraphs(limit: nil)
    }
    
    public func getGraph(id: GraphDef.ID) async throws -> GraphDef {
        try await dataStore.getGraph(id: id)
    }
    
    public func getTopNode(graphId: GraphDef.ID) async throws -> GraphNode {
        guard let node = try await dataStore.getNodes(graphId: graphId, limit: 1).first else {
            throw CoreDataGraphServiceError.noTopNodeFound
        }
        return node
    }
    
    public func getNode(id: GraphNode.ID, graphId: GraphDef.ID) async throws -> GraphNode {
        try await dataStore.getNode(id: id, graphId: graphId)
    }
    
    public func getEdges(source: GraphNode.ID, graphId: GraphDef.ID) async throws -> [GraphEdge] {
        try await dataStore.getEdges(source: source, graphId: graphId)
    }
    
    public func getEdges(target: GraphNode.ID, graphId: GraphDef.ID) async throws -> [GraphEdge] {
        try await dataStore.getEdges(target: target, graphId: graphId)
    }
}

public enum CoreDataGraphServiceError: String, LocalizedError {
    case noTopNodeFound
}
