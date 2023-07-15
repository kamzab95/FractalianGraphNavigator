//
// GraphFilesProviderMock.swift
// FractalianGraphNavigatorTests
//
// Created by Kamil Zaborowski on 15/07/2023
// Copyright © 2023 Kamil Zaborowski. All rights reserved.
//

import Foundation
@testable import FractalianGraphNavigator

class GraphFilesProviderMock: GraphFilesProvider {
    
    var mockResult_AllFiles = [GraphFile]()
    var mock_getAllFilesCallCounter = 0
    func getAllFiles() -> [GraphFile] {
        mock_getAllFilesCallCounter += 1
        return mockResult_AllFiles
    }
}
