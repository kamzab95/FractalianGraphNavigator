//
// MainCoordinatorViewModel.swift
// FractalianGraphNavigator
//
// Created by Kamil Zaborowski on 14/07/2023
// Copyright © 2023 Kamil Zaborowski. All rights reserved.
//

import SwiftUI
import Combine
import GraphService
import ModularModel

struct MainCoordinatorViewState {
    var navigationPath: NavigationPath = NavigationPath()
}

enum MainCoordinatorViewAction {
    case setNavigationPath(NavigationPath)
}

class MainCoordinatorViewModel: ViewModel {
    @Published var state: MainCoordinatorViewState = .init()
    
    private var mainCoordinator: MainCoordinator?
    
    private var cancelBag = Set<AnyCancellable>()
    
    init(container: Container) {
        self.state = state
        
        container.register(MainCoordinator.self) { _ in
            MainCoordinatorImpl()
        }.inObjectScope(.weak)
        
        mainCoordinator = container.resolve()
        
        bind()
    }
    
    func trigger(_ action: MainCoordinatorViewAction) async {
        switch action {
        case .setNavigationPath(let navigationPath):
            state.navigationPath = navigationPath
        }
    }
    
    private func bind() {
        mainCoordinator?.rootPublisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] root in
                self?.state.navigationPath.append(root)
            })
            .store(in: &cancelBag)
    }
}
