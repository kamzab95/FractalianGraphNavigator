//
// GraphDataStore.swift
// 
//
// Created by Kamil Zaborowski on 12/07/2023
// Copyright © 2023 Kamil Zaborowski. All rights reserved.
//

import Foundation
import CoreData
import GraphMLParser

public protocol GraphDataStoreQuery {
    func getGraphs(limit: Int?) async throws -> [GraphDef]
    func getGraph(id: GraphDef.ID) async throws -> GraphDef
    
    func getNodes(graphId: GraphDef.ID, limit: Int) async throws -> [GraphNode]
    func getNode(id: GraphNode.ID, graphId: GraphDef.ID) async throws -> GraphNode
    
    func getEdges(source: GraphNode.ID, graphId: GraphDef.ID) async throws -> [GraphEdge]
    func getEdges(target: GraphNode.ID, graphId: GraphDef.ID) async throws -> [GraphEdge]
}

public protocol GraphDataStoreCommand {
    func saveGraph(graph: GraphDef) throws
    func saveNode(node: GraphNode, graphId: GraphDef.ID, batchSize: Int) throws
    func saveEdge(edge: GraphEdge, graphId: GraphDef.ID, batchSize: Int) throws
    
    func saveIfNeeded() throws
}

public protocol GraphDataStore: GraphDataStoreQuery, GraphDataStoreCommand {
    
}

