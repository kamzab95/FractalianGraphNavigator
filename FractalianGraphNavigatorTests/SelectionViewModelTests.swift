//
// SelectionViewModelTests.swift
// FractalianGraphNavigatorTests
//
// Created by Kamil Zaborowski on 15/07/2023
// Copyright © 2023 Kamil Zaborowski. All rights reserved.
//

import XCTest
import GraphServiceMocks
@testable import FractalianGraphNavigator

final class SelectionViewModelTests: XCTestCase {

    var sut: SelectionViewModel!
    var graphServiceMock: GraphServiceMock!
    var graphFilesProvider: GraphFilesProviderMock!
    var mainCoordinatorMock: MainCoordinatorMock!
    
    override func setUpWithError() throws {
        graphServiceMock = GraphServiceMock()
        graphFilesProvider = GraphFilesProviderMock()
        mainCoordinatorMock = MainCoordinatorMock()
        
        sut = SelectionViewModel(
            graphService: graphServiceMock,
            graphFilesProvider: graphFilesProvider,
            mainCoordinator: mainCoordinatorMock)
    }
    
    func testViewDidLoad() async throws {
        await sut.trigger(.viewDidLoad)
        
        XCTAssertEqual(sut.state.errorMessage, nil)
        XCTAssertEqual(graphFilesProvider.mock_getAllFilesCallCounter, 1)
        XCTAssertEqual(graphServiceMock.mock_getGraphsCallCounter, 1)
    }
    
    func testOpenDatabase() async throws {
        let database = DatabaseInfo(id: "db1")
        await sut.trigger(.openDatabase(database))
        
        XCTAssertEqual(sut.state.errorMessage, nil)
        XCTAssertEqual(mainCoordinatorMock.mock_openNodeViewCallCounter, 1)
        XCTAssertEqual(mainCoordinatorMock.mock_openNodeViewCalled, database.id)
    }
    
    func testSelectGraphFile() async throws {
        let graphFile = GraphFile(name: "name", url: URL(string: "/")!)
        await sut.trigger(.selectGraphFile(graphFile))
        
        XCTAssertEqual(sut.state.errorMessage, nil)
        XCTAssertEqual(sut.state.selectedGraphFile, graphFile)
    }
    
    func testProcessGraphFile() async throws {
        let graphFile = GraphFile(name: "name", url: URL(string: "/")!)
        await sut.trigger(.selectGraphFile(graphFile))
        await sut.trigger(.processGraphFile)
        
        XCTAssertEqual(sut.state.errorMessage, nil)
        XCTAssertEqual(graphServiceMock.mock_loadGraphCallCounter, 1)
        XCTAssertEqual(graphServiceMock.mock_loadGraphCalled?.url, graphFile.url)
        XCTAssertEqual(graphServiceMock.mock_loadGraphCalled?.graphId, graphFile.name)
    }
    
    func testCloseError() async throws {
        sut.state.errorMessage = "message"
        await sut.trigger(.closeError)
        
        XCTAssertEqual(sut.state.errorMessage, nil)
    }
}
