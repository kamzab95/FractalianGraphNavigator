//
// AppDependencies.swift
// FractalianGraphNavigator
//
// Created by Kamil Zaborowski on 12/07/2023
// Copyright © 2023 Kamil Zaborowski. All rights reserved.
//

import Foundation
import Swinject
import GraphService

typealias Container = Swinject.Container

// MARK: - LIVE
class LiveContainerFactory {
    private init() { }
    
    static func build() -> Container {
        let container = Container()
        
        container.register(GraphService.self) { _ in
            return CoreDataGraphService(dataStore: CoreDataGraphDataStore())
        }.inObjectScope(.container)
        
        return container
    }
}

// MARK: - PREVIEW
class PreviewContainerFactory {
    private init() { }
    
    static func build() -> Container {
        let container = Container()
        
        container.register(GraphService.self) { _ in
            return CoreDataGraphService(dataStore: CoreDataGraphDataStore(inMemory: true))
        }.inObjectScope(.container)
        
        return container
    }
}
