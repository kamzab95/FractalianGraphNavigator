//
// NodeView.swift
// FractalianGraphNavigator
//
// Created by Kamil Zaborowski on 08/07/2023
// Copyright © 2023 Kamil Zaborowski. All rights reserved.
//

import SwiftUI
import GraphService
import ModularModel

struct NodeView: View {
    @StateObject var viewModel: AnyViewModelOf<NodeViewModel>
    
    init(graph: GraphDef.ID, container: Container) {
        self._viewModel = NodeViewModel(graph: graph, container: container).eraseToStateObject()
    }
    
    var body: some View {
        VStack {
            ZStack {
                if let nodeTree = viewModel.nodeTree {
                   contentView(nodeTree: nodeTree)
                } else {
                    ZStack(alignment: .center) {
                        VStack(spacing: 8) {
                            ProgressView()
                            Text("Loading")
                        }
                    }
                }
            }
            .onAppear {
                viewModel.trigger(.viewDidLoad)
            }
        }
        .alert(viewModel.errorMessage ?? "", isPresented: viewModel.binding(\.errorVisible, input: { _ in .closeError })) {
            Button("Cancel", role: .cancel) {}
        }
    }
    
    @ViewBuilder
    func contentView(nodeTree: NodeTree) -> some View {
        VStack {
            let node = nodeTree.node
            Text("\(node.id)")
                .frame(maxWidth: .infinity, minHeight: 30)
                .background(Color.gray)
                .cornerRadius(8)
                .padding(8)
            
            ScrollView {
                Text("\(node.dataDescription)")
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: 160)
            
            ScrollView {
                NodesGridView(nodeTrees: nodeTree.children) { nodeId in
                    viewModel.trigger(.loadNode(nodeId))
                }
            }
            .frame(minWidth: 50, minHeight: 50)
        }
        .padding(.top, 2)
    }
}

extension GraphNode {
    var dataDescription: String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let encoded = try encoder.encode(elements)
            return String(data: encoded, encoding: .utf8) ?? ""
        } catch {
            return "Failed to encode \(elements)"
        }
    }
}

//struct NodeView_Previews: PreviewProvider {
//    static var container = PreviewContainerFactory.build()
//
//    static var previews: some View {
//        NodeView(container: container)
//            .frame(minWidth: 300, minHeight: 500)
//    }
//}