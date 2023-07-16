//
// GraphMLParserTests.swift
// 
//
// Created by Kamil Zaborowski on 08/07/2023
// Copyright © 2023 Kamil Zaborowski. All rights reserved.
//

import XCTest
@testable import GraphMLParser

final class GraphMLParserTests: XCTestCase {
    
    var sut: GraphMLParserImpl!
    var mockGraphMLParserStorage: MockGraphMLParserStorage!
    
    override func setUp() async throws {
        mockGraphMLParserStorage = MockGraphMLParserStorage()
        sut = GraphMLParserImpl()
        sut.delegate = mockGraphMLParserStorage
    }
    
    func testParse() throws {
        let url = Bundle.module.url(forResource: "organic2", withExtension: "graphml")!
        try sut.parse(url: url)
        
        XCTAssertEqual(mockGraphMLParserStorage.nodes.count, 123)
        XCTAssertEqual(mockGraphMLParserStorage.edges.count, 243)
        XCTAssertEqual(mockGraphMLParserStorage.nodes.last?.id, "n122")
        XCTAssertEqual(mockGraphMLParserStorage.edges.last, GraphEdge(source: "n122", target: "n121"))
        XCTAssertEqual(mockGraphMLParserStorage.graphMLParserDidCompletedCallCounter, 1)
    }
}

class MockGraphMLParserStorage: GraphMLParserDelegate {
    var graph: GraphConfig?
    func graphMLParser(parsed graph: GraphConfig) {
        self.graph = graph
    }
    
    var nodes = [GraphNode]()
    func graphMLParser(parsed node: GraphNode) {
        nodes.append(node)
    }
    
    var edges = [GraphEdge]()
    func graphMLParser(parsed edge: GraphEdge) {
        edges.append(edge)
    }
    
    var graphMLParserDidCompletedCallCounter = 0
    func graphMLParserDidCompleted() {
        graphMLParserDidCompletedCallCounter += 1
    }
}

extension GraphEdge: Equatable {
    public static func == (lhs: GraphEdge, rhs: GraphEdge) -> Bool {
        lhs.source == rhs.source &&
        rhs.source == rhs.source
    }
}
