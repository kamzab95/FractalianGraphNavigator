//
// CoreDataGraphDataStoreTests.swift
// 
//
// Created by Kamil Zaborowski on 12/07/2023
// Copyright © 2023 Kamil Zaborowski. All rights reserved.
//

import XCTest
@testable import GraphService

final class CoreDataGraphDataStoreTests: XCTestCase {
    
    var sut: CoreDataGraphDataStore!
    var defaultGraphId: GraphDef.ID!
    
    override func setUp() async throws {
        sut = CoreDataGraphDataStore(inMemory: true)
        
        let defaultGraph = GraphDef(id: "1", directed: true)
        defaultGraphId = defaultGraph.id
        try sut.saveGraph(graph: defaultGraph)
    }
    
    func testSaveAndRestoreGraph() async throws {
        let graph = GraphDef(id: "n1", directed: true)
        try sut.saveGraph(graph: graph)
        
        let restored = try await sut.getGraph(id: graph.id)
        XCTAssertEqual(restored, graph)
    }
    
    func testSaveAndRestoreNode() async throws {
        let node = GraphNode(id: "n1", attributes: [:], elements: [])
        try sut.saveNode(node: node, graphId: defaultGraphId, batchSize: 0)
        
        let restored = try await sut.getNode(id: node.id, graphId: defaultGraphId)
        XCTAssertEqual(node, restored)
    }
    
    func testSaveAndRestoreNodes() async throws {
        for i in 0...5 {
            let node = GraphNode(id: "n\(i)", attributes: [:], elements: [])
            try sut.saveNode(node: node, graphId: defaultGraphId, batchSize: 0)
        }
        
        let restored = try await sut.getNodes(graphId: defaultGraphId, limit: 3)
        let expectedIds = ["n0", "n1", "n2"]
        
        XCTAssertEqual(restored.count, 3)
        XCTAssertEqual(restored.map({ $0.id }), expectedIds)
    }
    
    func testGetEdgeBySource() async throws {
        let node1 = GraphNode(id: "n1", attributes: [:], elements: [])
        let node2 = GraphNode(id: "n2", attributes: [:], elements: [])
        let node3 = GraphNode(id: "n3", attributes: [:], elements: [])
        
        let edge1 = GraphEdge(source: node1.id, target: node2.id)
        let edge2 = GraphEdge(source: node2.id, target: node3.id)
        let edge3 = GraphEdge(source: node1.id, target: node3.id)
        
        try sut.saveNode(node: node1, graphId: defaultGraphId, batchSize: 0)
        try sut.saveNode(node: node2, graphId: defaultGraphId, batchSize: 0)
        try sut.saveNode(node: node3, graphId: defaultGraphId, batchSize: 0)
        
        try sut.saveEdge(edge: edge1, graphId: defaultGraphId, batchSize: 0)
        try sut.saveEdge(edge: edge2, graphId: defaultGraphId, batchSize: 0)
        try sut.saveEdge(edge: edge3, graphId: defaultGraphId, batchSize: 0)
        
        let restored = try await sut.getEdges(source: node1.id, graphId: defaultGraphId)
        XCTAssertEqual(Set([edge1, edge3]), Set(restored))
    }
    
    func testGetEdgeByTarget() async throws {
        let node1 = GraphNode(id: "n1", attributes: [:], elements: [])
        let node2 = GraphNode(id: "n2", attributes: [:], elements: [])
        let node3 = GraphNode(id: "n3", attributes: [:], elements: [])
        
        let edge1 = GraphEdge(source: node1.id, target: node2.id)
        let edge2 = GraphEdge(source: node2.id, target: node3.id)
        let edge3 = GraphEdge(source: node1.id, target: node3.id)
        
        try sut.saveNode(node: node1, graphId: defaultGraphId, batchSize: 0)
        try sut.saveNode(node: node2, graphId: defaultGraphId, batchSize: 0)
        try sut.saveNode(node: node3, graphId: defaultGraphId, batchSize: 0)
        
        try sut.saveEdge(edge: edge1, graphId: defaultGraphId, batchSize: 0)
        try sut.saveEdge(edge: edge2, graphId: defaultGraphId, batchSize: 0)
        try sut.saveEdge(edge: edge3, graphId: defaultGraphId, batchSize: 0)
        
        try sut.saveIfNeeded()
        
        let restored = try await sut.getEdges(target: node2.id, graphId: defaultGraphId)
        XCTAssertEqual(Set([edge1]), Set(restored))
    }
}

extension GraphNode: Equatable {
    public static func == (lhs: GraphNode, rhs: GraphNode) -> Bool {
        lhs.id == rhs.id
    }
}

extension GraphDef: Equatable {
    public static func == (lhs: GraphDef, rhs: GraphDef) -> Bool {
        lhs.id == rhs.id &&
        lhs.directed == rhs.directed
    }
}

extension GraphEdge: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(source)
        hasher.combine(target)
    }
    
    public static func == (lhs: GraphEdge, rhs: GraphEdge) -> Bool {
        lhs.source == rhs.source &&
        lhs.target == rhs.target
    }
    
}
