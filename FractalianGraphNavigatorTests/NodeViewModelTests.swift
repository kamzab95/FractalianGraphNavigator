//
// NodeViewModelTests.swift
// FractalianGraphNavigatorTests
//
// Created by Kamil Zaborowski on 15/07/2023
// Copyright © 2023 Kamil Zaborowski. All rights reserved.
//

import XCTest
import GraphServiceMocks
import GraphService
@testable import FractalianGraphNavigator

final class NodeViewModelTests: XCTestCase {
    
    var sut: NodeViewModel!
    
    var graphId: GraphDef.ID!
    var graphServiceMock: GraphServiceMock!

    override func setUpWithError() throws {
        graphId = "g1"
        graphServiceMock = GraphServiceMock()
        sut = NodeViewModel(graph: graphId, graphService: graphServiceMock)
        
        graphServiceMock.mockResult_graphs = [GraphDef(id: graphId, directed: true)]
    }
    
    func testViewDidLoad() async throws {
        let node = GraphNode(id: "n1", attributes: [:], elements: [])
        graphServiceMock.mockResult_nodes = [graphId: [node]]
        
        await sut.trigger(.viewDidLoad)
        
        XCTAssertEqual(graphServiceMock.mock_getTopNodeCallCounter, 1)
        XCTAssertEqual(graphServiceMock.mock_getNodeCallCounter, 1)
        XCTAssertEqual(sut.state.nodeTree?.node, node)
    }
    
    func testLoadNode() async throws {
        let node = GraphNode(id: "n1", attributes: [:], elements: [])
        graphServiceMock.mockResult_nodes = [graphId: [node]]
        
        await sut.trigger(.loadNode(node.id))
        
        XCTAssertEqual(graphServiceMock.mock_getNodeCallCounter, 1)
        XCTAssertEqual(sut.state.nodeTree?.node, node)
    }
    
    func testCloseError() async throws {
        sut.state.errorMessage = "message"
        
        await sut.trigger(.closeError)
        
        XCTAssertEqual(sut.state.errorMessage, nil)
    }
}

extension GraphNode: Equatable {
    public static func == (lhs: GraphNode, rhs: GraphNode) -> Bool {
        lhs.id == rhs.id &&
        lhs.attributes == rhs.attributes &&
        lhs.elements == rhs.elements
    }
}

extension GenericElement: Equatable {
    public static func == (lhs: GenericElement, rhs: GenericElement) -> Bool {
        lhs.name == rhs.name &&
        lhs.text == rhs.text &&
        lhs.attributes == rhs.attributes &&
        lhs.children == rhs.children
    }
}
