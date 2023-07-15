//
// GraphService.swift
//
//
// Created by Kamil Zaborowski on 12/07/2023
// Copyright © 2023 Kamil Zaborowski. All rights reserved.
//

import Foundation
import GraphMLParser

public protocol GraphService {
    func loadGraph(url: URL, graphId: String) async throws
    
    func getGraphs() async throws -> [GraphDef]
    func getGraph(id: GraphDef.ID) async throws -> GraphDef
    func getTopNode(graphId: GraphDef.ID) async throws -> GraphNode
    func getNode(id: GraphNode.ID, graphId: GraphDef.ID) async throws -> GraphNode
    func getEdges(source: GraphNode.ID, graphId: GraphDef.ID) async throws -> [GraphEdge]
    func getEdges(target: GraphNode.ID, graphId: GraphDef.ID) async throws -> [GraphEdge]
}

extension GraphService {
    public func getConnectedNodes(nodeId: GraphNode.ID, graphId: GraphDef.ID) async throws -> [GraphNode] {
        let graph = try await getGraph(id: graphId)
        let directed = graph.directed
        
        var nodes = [GraphNode.ID: GraphNode]()
        
        var edges = try await getEdges(source: nodeId, graphId: graphId)
        
        for edge in edges {
            let node = try await getNode(id: edge.target, graphId: graphId)
            nodes[node.id] = node
        }
        
        if !directed {
            edges = try await getEdges(target: nodeId, graphId: graphId)
            for edge in edges {
                let node = try await getNode(id: edge.source, graphId: graphId)
                nodes[node.id] = node
            }
        }
        
        return Array(nodes.values)
    }
}

public typealias GraphEdge = GraphMLParser.GraphEdge
public typealias GraphNode = GraphMLParser.GraphNode
public typealias GenericElement = GraphMLParser.GenericElement

// using GraphNode.ID where GraphNode is alias for GraphMLParser.GraphNode causes warnings
public typealias GraphNodeID = GraphMLParser.GraphNode.ID

public struct GraphDef: Identifiable {
    public var id: String
    public var directed: Bool
    
    public init(id: String, directed: Bool) {
        self.id = id
        self.directed = directed
    }
}
