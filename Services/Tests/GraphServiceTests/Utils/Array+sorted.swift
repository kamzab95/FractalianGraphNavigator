//
// Array+sorted.swift
// 
//
// Created by Kamil Zaborowski on 10/07/2023
// Copyright © 2023 Kamil Zaborowski. All rights reserved.
//

import Foundation

extension Array {
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        return self.sorted { $0[keyPath: keyPath] < $1[keyPath: keyPath] }
    }
}
