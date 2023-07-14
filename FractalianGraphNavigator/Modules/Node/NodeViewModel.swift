//
// NodeViewModel.swift
// FractalianGraphNavigator
//
// Created by Kamil Zaborowski on 14/07/2023
// Copyright © 2023 Kamil Zaborowski. All rights reserved.
//

import Foundation
import GraphService
import ModularModel

struct NodeTree: Identifiable, Equatable {
    var id: GraphNode.ID { node.id }
    var node: GraphNode
    var children: [NodeTree]
    
    static func == (lhs: NodeTree, rhs: NodeTree) -> Bool {
        lhs.id == rhs.id
    }
}

struct NodeViewState {
    let graph: GraphDef.ID
    var nodeTree: NodeTree?
    var errorMessage: String?
}

extension NodeViewState {
    var errorVisible: Bool { errorMessage != nil }
}

enum NodeViewAction {
    case viewDidLoad
    case loadNode(GraphNode.ID)
    case closeError
}

class NodeViewModel: ViewModel {
    static let MAX_DEPTH = 3
    
    @Published var state: NodeViewState
    
    private var graphId: GraphDef.ID {
        state.graph
    }
    
    private let graphService: GraphService
    
    init(graph: GraphDef.ID, container: Container) {
        self.state = .init(graph: graph)
        self.graphService = container.resolve()!
    }
    
    func trigger(_ action: NodeViewAction) async {
        do {
            switch action {
            case .viewDidLoad:
                try await self.viewDidLoad()
            case .loadNode(let nodeId):
                try await loadNode(nodeId)
            case .closeError:
                state.errorMessage = nil
            }
        } catch {
            state.errorMessage = error.localizedDescription
        }
    }
    
    // MARK: PRIVATE
    
    private func viewDidLoad() async throws {
        let topNode = try await graphService.getTopNode(graphId: graphId)
        try await loadNode(topNode.id)
    }
    
    private func loadNode(_ nodeId: GraphNode.ID) async throws {
        let node = try await graphService.getNode(id: nodeId, graphId: graphId)
        let nodeTree = try await buildNodeTree(nodeId: nodeId)
        state.nodeTree = NodeTree(node: node, children: nodeTree)
    }
    
    private func buildNodeTree(nodeId: GraphNode.ID, depth: Int = 0) async throws -> [NodeTree] {
        guard depth < NodeViewModel.MAX_DEPTH else {
            return []
        }
        
        let depth = depth + 1
        let nodes = try await graphService.getConnectedNodes(nodeId: nodeId, graphId: graphId)
        
        var trees = [NodeTree]()
        for node in nodes {
            let children = try await buildNodeTree(nodeId: node.id, depth: depth)
            let tree = NodeTree(node: node, children: children)
            trees.append(tree)
        }
        
        trees.sort(by: { $0.id < $1.id })
        return trees
    }
}
