//
// CodableValueTransformer.swift
// 
//
// Created by Kamil Zaborowski on 15/07/2023
// Copyright © 2023 Kamil Zaborowski. All rights reserved.
//

import Foundation
import CoreData

class CodableValueTransformer<Item: Codable>: ValueTransformer {
    static func register(name: String) {
        let transformer = CodableValueTransformer<Item>()
        let transformerName = NSValueTransformerName(rawValue: name)
        ValueTransformer.setValueTransformer(transformer, forName: transformerName)
    }
    
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let elements = value as? Item else { return nil }
        return try? encoder.encode(elements)
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        return try? decoder.decode(Item.self, from: data)
    }
}
