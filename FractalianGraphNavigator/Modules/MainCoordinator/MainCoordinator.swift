//
// MainCoordinator.swift
// FractalianGraphNavigator
//
// Created by Kamil Zaborowski on 14/07/2023
// Copyright © 2023 Kamil Zaborowski. All rights reserved.
//

import Foundation
import GraphService
import Combine

enum MainCoordinatorRoots: Hashable {
    case nodeView(graphId: GraphDef.ID)
}

protocol MainCoordinator {
    var rootPublisher: AnyPublisher<MainCoordinatorRoots, Never> { get }
    func openNodeView(graphId: GraphDef.ID)
}

class MainCoordinatorImpl: MainCoordinator {
    var rootPublisher: AnyPublisher<MainCoordinatorRoots, Never> {
        rootSubject.eraseToAnyPublisher()
    }
    
    private let rootSubject = PassthroughSubject<MainCoordinatorRoots, Never>()
    
    func openNodeView(graphId: GraphDef.ID) {
        rootSubject.send(.nodeView(graphId: graphId))
    }
}
