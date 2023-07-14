//
// Resolver+resolve.swift
// FractalianGraphNavigator
//
// Created by Kamil Zaborowski on 12/07/2023
// Copyright © 2023 Kamil Zaborowski. All rights reserved.
//

import Foundation
import Swinject

public extension Resolver {
    func resolve<Service>(_ serviceType: Service.Type = Service.self) -> Service? {
        resolve(serviceType)
    }
}
