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
    let columnWidth: CGFloat
    let openNode: (GraphNode.ID)->Void
    
    var body: some View {
        let columnWidth = max(180, columnWidth)
        let columns = [
            GridItem(.adaptive(minimum: columnWidth * 0.67, maximum: columnWidth))
        ]
        LazyVGrid(columns: columns) {
            ForEach(nodeTrees) { nodeTree in
                NodeRectangleView(nodeTree: nodeTree, columnWidth: columnWidth) { nodeId in
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
    let columnWidth: CGFloat
    let openNode: (GraphNode.ID)->Void
    
    var body: some View {
        VStack(spacing: 0) {
            Text(nodeTree.node.id)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .padding(8)
                .background(Color.blue)
            
            if nodeTree.children.count > 0 {
                NodesGridView(nodeTrees: nodeTree.children, columnWidth: columnWidth/3, openNode: openNode)
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
