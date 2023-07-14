//
// NSPersistentContainer+initBundle.swift
// 
//
// Created by Kamil Zaborowski on 13/07/2023
// Copyright © 2023 Kamil Zaborowski. All rights reserved.
//

import Foundation
import CoreData

extension NSPersistentContainer {
    public convenience init(name: String, bundle: Bundle) {
        guard let modelURL = bundle.url(forResource: name, withExtension: "momd"),
            let mom = NSManagedObjectModel(contentsOf: modelURL)
            else {
                fatalError("Unable to located Core Data model")
        }

        self.init(name: name, managedObjectModel: mom)
    }
}
