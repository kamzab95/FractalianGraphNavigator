//
// GraphProcessor.swift
//
//
// Created by Kamil Zaborowski on 14/07/2023
// Copyright © 2023 Kamil Zaborowski. All rights reserved.
//

import Foundation
import GraphMLParser

class GraphProcessor {
    
    private let dataStore: GraphDataStore
    private var graphMLParser: GraphParser?
    
    private let graphId: String
    
    public required init(graphId: String, dataStore: GraphDataStore) {
        self.graphId = graphId
        self.dataStore = dataStore
    }
    
    public func loadGraph(url: URL) throws {
        self.graphMLParser = GraphMLParserImpl()
        self.graphMLParser?.delegate = self
        self.graphMLParser?.parse(url: url)
    }
}

extension GraphProcessor: GraphMLParserDelegate {
    public func graphMLParser(parsed graphConfig: GraphConfig) {
        let graph = GraphDef(id: graphId, directed: graphConfig.directed)
        try? dataStore.saveGraph(graph: graph)
    }
    
    public func graphMLParser(parsed node: GraphNode) {
        try? dataStore.saveNode(node: node, graphId: graphId, batchSize: 500)
    }
    
    public func graphMLParser(parsed edge: GraphEdge) {
        try? dataStore.saveEdge(edge: edge, graphId: graphId, batchSize: 500)
    }
    
    public func graphMLParserDidCompleted() {
        try? dataStore.saveIfNeeded()
    }
}
