//
// TestDependencies.swift
// FractalianGraphNavigatorTests
//
// Created by Kamil Zaborowski on 12/07/2023
// Copyright © 2023 Kamil Zaborowski. All rights reserved.
//

import Foundation

class TestContainerFactory {
    static func build() -> Container {
        let container = Container()
        container.register(GraphService.self) { _ in
            let url = Bundle.main.url(forResource: "hierarchical1", withExtension: "graphml")!
            let globalGraph = GraphMLParser().parse(url: url)
            return InMemoryGraphService(graph: globalGraph)
        }.inObjectScope(.container)
        return container
    }
}
