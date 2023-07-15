//
// GraphFilesProvider.swift
// FractalianGraphNavigator
//
// Created by Kamil Zaborowski on 15/07/2023
// Copyright © 2023 Kamil Zaborowski. All rights reserved.
//

import Foundation

struct GraphFile: Hashable {
    var name: String
    var url: URL
}

protocol GraphFilesProvider {
    func getAllFiles() -> [GraphFile]
}

class BundleGraphFilesProvider: GraphFilesProvider {
    func getAllFiles() -> [GraphFile] {
        let urls = Bundle.main.urls(forResourcesWithExtension: "graphml", subdirectory: nil) ?? []
        let graphFiles = urls.map({ url in
            let name = url.deletingPathExtension().lastPathComponent
            return GraphFile(name: name, url: url)
        })
        return graphFiles
    }
}
