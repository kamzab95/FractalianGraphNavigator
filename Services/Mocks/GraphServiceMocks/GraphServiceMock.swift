//
// GraphServiceMock.swift
// 
//
// Created by Kamil Zaborowski on 15/07/2023
// Copyright © 2023 Kamil Zaborowski. All rights reserved.
//

import Foundation
import GraphService

public class GraphServiceMock: GraphService {
    
    public init() {
        
    }
    
    public var mock_loadGraphCalled: (url: URL, graphId: String)?
    public var mock_loadGraphCallCounter = 0
    public func loadGraph(url: URL, graphId: String) async throws {
        mock_loadGraphCallCounter += 1
        mock_loadGraphCalled = (url, graphId)
    }
    
    public var mockResult_graphs = [GraphDef]()
    public var mock_getGraphsCallCounter = 0
    public func getGraphs() async throws -> [GraphDef] {
        mock_getGraphsCallCounter += 1
        return mockResult_graphs
    }
    
    public var mock_getGraphCallCounter = 0
    public func getGraph(id: GraphDef.ID) async throws -> GraphDef {
        mock_getGraphCallCounter += 1
        guard let graph = mockResult_graphs.first(where: { $0.id == id }) else {
            throw GraphServiceMockError.mockError
        }
        return graph
    }
    
    public var mock_getTopNodeCallCounter = 0
    public func getTopNode(graphId: GraphDef.ID) async throws -> GraphNode {
        mock_getTopNodeCallCounter += 1
        guard let node = mockResult_nodes[graphId]?.first else {
            throw CoreDataGraphServiceError.noTopNodeFound
        }
        return node
    }
    
    public var mockResult_nodes = [GraphDef.ID: [GraphNode]]()
    public var mock_getNodeCallCounter = 0
    public func getNode(id: GraphNodeID, graphId: GraphDef.ID) async throws -> GraphNode {
        mock_getNodeCallCounter += 1
        guard let node = mockResult_nodes[graphId]?.first(where: { $0.id == id }) else {
            throw GraphServiceMockError.mockError
        }
        return node
    }
    
    public var mockResult_edges = [GraphDef.ID: [GraphEdge]]()
    public var mock_getEdgesBySourceCallCounter = 0
    public func getEdges(source: GraphNodeID, graphId: GraphDef.ID) async throws -> [GraphEdge] {
        mock_getEdgesBySourceCallCounter += 1
        return mockResult_edges[graphId]?.filter({ $0.source == source }) ?? []
    }
    
    public var mock_getEdgesByTargetCallCounter = 0
    public func getEdges(target: GraphNodeID, graphId: GraphDef.ID) async throws -> [GraphEdge] {
        mock_getEdgesByTargetCallCounter += 1
        return mockResult_edges[graphId]?.filter({ $0.target == target }) ?? []
    }
}

enum GraphServiceMockError: Error {
    case mockError
}
