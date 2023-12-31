//
// FractalianGraphNavigatorApp.swift
// FractalianGraphNavigator
//
// Created by Kamil Zaborowski on 07/07/2023
// Copyright © 2023 Kamil Zaborowski. All rights reserved.
//

import SwiftUI
import ModularModel
import GraphService

@main
struct FractalianGraphNavigatorApp: App {
    @State var container = LiveContainerFactory.build()
    
    var body: some Scene {
        WindowGroup {
            MainCoordinatorView(container: container)
        }
    }
}
