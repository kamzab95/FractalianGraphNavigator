//
// NodeRectangleView.swift
// FractalianGraphNavigator
//
// Created by Kamil Zaborowski on 11/07/2023
// Copyright © 2023 Kamil Zaborowski. All rights reserved.
//

import SwiftUI
import GraphService

struct NodesGridView: View {
    let nodeTrees: [NodeTree]
    let openNode: (GraphNode.ID)->Void
    
    var body: some View {
        let columns = [
            GridItem(.adaptive(minimum: 120))
        ]
        LazyVGrid(columns: columns) {
            ForEach(nodeTrees) { nodeTree in
                NodeRectangleView(nodeTree: nodeTree) { nodeId in
                    openNode(nodeId)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(Color.white)
    }
}

struct NodeRectangleView: View {
    let nodeTree: NodeTree
    let openNode: (GraphNode.ID)->Void
    
    var body: some View {
        VStack(spacing: 0) {
            Text(nodeTree.node.id)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .padding(8)
                .background(Color.blue)
            
            if nodeTree.children.count > 0 {
                NodesGridView(nodeTrees: nodeTree.children, openNode: openNode)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 3)
        .padding(8)
        .onTapGesture {
            withAnimation {
                openNode(nodeTree.node.id)
            }
        }
    }
}
