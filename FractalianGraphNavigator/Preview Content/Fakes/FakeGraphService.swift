//
// FakeGraphService.swift
// FractalianGraphNavigator
//
// Created by Kamil Zaborowski on 15/07/2023
// Copyright © 2023 Kamil Zaborowski. All rights reserved.
//

import Foundation
import GraphService

public class FakeGraphService: GraphService {
    private var graphs: [String: GraphDef] = [:]
    private var nodes: [String: [GraphNode]] = [:]
    private var edges: [String: [GraphEdge]] = [:]

    public init() {
        seed()
    }

    public func loadGraph(url: URL, graphId: String) async throws {
        try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
    }
    
    public func getGraphs() async throws -> [GraphDef] {
        return Array(graphs.values)
    }

    public func getGraph(id: GraphDef.ID) async throws -> GraphDef {
        guard let graph = graphs[id] else { throw NSError() }
        return graph
    }

    public func getTopNode(graphId: GraphDef.ID) async throws -> GraphNode {
        guard let node = nodes[graphId]?.first else { throw NSError() }
        return node
    }

    public func getNode(id: GraphNodeID, graphId: GraphDef.ID) async throws -> GraphNode {
        guard let nodes = nodes[graphId], let node = nodes.first(where: { $0.id == id }) else { throw NSError() }
        return node
    }

    public func getEdges(source: GraphNodeID, graphId: GraphDef.ID) async throws -> [GraphEdge] {
        guard let graphEdges = edges[graphId] else { throw NSError() }
        return graphEdges.filter { $0.source == source }
    }

    public func getEdges(target: GraphNodeID, graphId: GraphDef.ID) async throws -> [GraphEdge] {
        guard let graphEdges = edges[graphId] else { throw NSError() }
        return graphEdges.filter { $0.target == target }
    }
    
    func seed() {
        for graphIndex in 1...3 {
            let graphId = "g\(graphIndex)"
            let graphDef = GraphDef(id: graphId, directed: false)
            
            var nodes = [GraphNode]()
            for i in 0...10 {
                let node = GraphNode(id: "node\(i)", attributes: [:], elements: [])
                nodes.append(node)
            }
            
            var edges = [GraphEdge]()
            for _ in 0...20 {
                let source = nodes.randomElement()!.id
                let target = nodes.randomElement()!.id
                let edge = GraphEdge(source: source, target: target)
                edges.append(edge)
            }

            self.graphs[graphId] = graphDef
            self.nodes[graphId] = nodes
            self.edges[graphId] = edges
        }
    }
}
