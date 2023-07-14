//
// MainCoordinatorView.swift
// FractalianGraphNavigator
//
// Created by Kamil Zaborowski on 14/07/2023
// Copyright © 2023 Kamil Zaborowski. All rights reserved.
//

import SwiftUI
import GraphService
import ModularModel

struct MainCoordinatorView: View {
    @StateObject var viewModel: AnyViewModelOf<MainCoordinatorViewModel>
    let container: Container
    
    init(container: Container) {
        self.container = container
        _viewModel = MainCoordinatorViewModel(container: container).eraseToStateObject()
    }
    
    var body: some View {
        NavigationStack(path: viewModel.binding(\.navigationPath, input: { .setNavigationPath($0) })) {
            SelectionView(container: container)
                .navigationDestination(for: MainCoordinatorRoots.self) { destination in
                    switch destination {
                    case .nodeView(let graph):
                        NodeView(graph: graph, container: container)
                    }
                }
        }
    }
}

struct MainCoordinatorView_Previews: PreviewProvider {
    static let container = PreviewContainerFactory.build()
    static var previews: some View {
        MainCoordinatorView(container: container)
    }
}
