//
// PreviewContainerFactory.swift
// FractalianGraphNavigator
//
// Created by Kamil Zaborowski on 15/07/2023
// Copyright © 2023 Kamil Zaborowski. All rights reserved.
//

import Foundation
import GraphService
import Swinject

class PreviewContainerFactory {
    private init() { }
    
    static func build() -> Container {
        let container = Container()
        
        container.register(GraphService.self) { _ in
            FakeGraphService()
        }.inObjectScope(.container)
        
        container.register(GraphFilesProvider.self) { _ in
            BundleGraphFilesProvider()
        }.inObjectScope(.container)
        
        return container
    }
}
