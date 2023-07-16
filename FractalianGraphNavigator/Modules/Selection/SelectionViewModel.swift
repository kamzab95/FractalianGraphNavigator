//
// SelectionViewModel.swift
// FractalianGraphNavigator
//
// Created by Kamil Zaborowski on 14/07/2023
// Copyright © 2023 Kamil Zaborowski. All rights reserved.
//

import Foundation
import ModularModel
import GraphService

struct DatabaseInfo: Identifiable {
    var id: String
}

struct SelectionViewState {
    var existingDatabases: [DatabaseInfo] = []
    var graphFiles: [GraphFile] = []
    var selectedGraphFile: GraphFile?
    var processing = false
    var errorMessage: String?
}

extension SelectionViewState {
    var errorVisible: Bool { errorMessage != nil }
}

enum SelectionViewAction {
    case viewDidLoad
    case openDatabase(DatabaseInfo)
    case selectGraphFile(GraphFile?)
    case processGraphFile
    case closeError
}

class SelectionViewModel: ViewModel {
    
    @Published var state: SelectionViewState = .init()
    
    private let graphService: GraphService
    private let graphFilesProvider: GraphFilesProvider
    private var mainCoordinator: MainCoordinator?
    
    convenience init(container: Container) {
        self.init(graphService: container.resolve()!,
                  graphFilesProvider: container.resolve()!,
                  mainCoordinator: container.resolve())
    }
    
    init(graphService: GraphService, graphFilesProvider: GraphFilesProvider, mainCoordinator: MainCoordinator?) {
        self.graphService = graphService
        self.graphFilesProvider = graphFilesProvider
        self.mainCoordinator = mainCoordinator
    }
    
    func trigger(_ action: SelectionViewAction) async {
        do {
            switch action {
            case .viewDidLoad:
                loadAvailableFiles()
                try await loadExistingDatabases()
            case .openDatabase(let databaseInfo):
                mainCoordinator?.openNodeView(graphId: databaseInfo.id)
            case .selectGraphFile(let name):
                state.selectedGraphFile = name
            case .processGraphFile:
                try await processGraphFile()
            case .closeError:
                state.errorMessage = nil
                try await loadExistingDatabases()
            }
        } catch {
            state.errorMessage = error.localizedDescription
            state.processing = false
        }
    }
    
    private func loadAvailableFiles() {
        state.graphFiles = graphFilesProvider.getAllFiles().sorted(by: { $0.name < $1.name })
        state.selectedGraphFile = state.graphFiles.first
    }
    
    private func loadExistingDatabases() async throws {
        let graphs = try await graphService.getGraphs()
        state.existingDatabases = graphs.map({
            DatabaseInfo(id: $0.id)
        })
    }
    
    private func processGraphFile() async throws {
        guard let graphFile = state.selectedGraphFile else {
            return
        }
        state.processing = true
        
        try await graphService.loadGraph(url: graphFile.url, graphId: graphFile.name)

        state.processing = false
        try await loadExistingDatabases()
    }
}
