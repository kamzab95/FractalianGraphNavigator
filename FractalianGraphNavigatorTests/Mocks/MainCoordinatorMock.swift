//
// MainCoordinatorMock.swift
// FractalianGraphNavigatorTests
//
// Created by Kamil Zaborowski on 15/07/2023
// Copyright © 2023 Kamil Zaborowski. All rights reserved.
//

import Foundation
import Combine
import GraphService
@testable import FractalianGraphNavigator

class MainCoordinatorMock: MainCoordinator {
    var rootPublisher: AnyPublisher<FractalianGraphNavigator.MainCoordinatorRoots, Never> = Empty().eraseToAnyPublisher()
    
    var mock_openNodeViewCallCounter = 0
    var mock_openNodeViewCalled: GraphDef.ID?
    func openNodeView(graphId: GraphDef.ID) {
        mock_openNodeViewCallCounter += 1
        mock_openNodeViewCalled = graphId
    }
}
