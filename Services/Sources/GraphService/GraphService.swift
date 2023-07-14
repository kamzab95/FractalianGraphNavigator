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
    func getTopNode(graphId: GraphDef.ID) async throws -> GraphNode
    func getNode(id: GraphNode.ID, graphId: GraphDef.ID) async throws -> GraphNode
    func getEdges(source: GraphNode.ID, graphId: GraphDef.ID) async throws -> [GraphEdge]
    func getEdges(target: GraphNode.ID, graphId: GraphDef.ID) async throws -> [GraphEdge]
    
    func getConnectedNodes(nodeId: GraphNode.ID, graphId: GraphDef.ID) async throws -> [GraphNode]
}

public typealias GraphEdge = GraphMLParser.GraphEdge
public typealias GraphNode = GraphMLParser.GraphNode

public struct GraphDef: Identifiable {
    public var id: String
    public var directed: Bool
}
