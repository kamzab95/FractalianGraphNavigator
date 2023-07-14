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
    var graphFiles: [String] = []
    var selectedGraphFile: String = ""
    var processing = false
    var errorMessage: String?
}

extension SelectionViewState {
    var errorVisible: Bool { errorMessage != nil }
}

enum SelectionViewAction {
    case viewDidLoad
    case openDatabase(DatabaseInfo)
    case selectGraphFile(String)
    case processGraphFile
    case closeError
}

class SelectionViewModel: ViewModel {
    
    @Published var state: SelectionViewState = .init()
    
    private let graphService: GraphService
    private var mainCoordinator: MainCoordinator?
    
    init(container: Container) {
        graphService = container.resolve()!
        mainCoordinator = container.resolve()
    }
    
    func trigger(_ action: SelectionViewAction) async {
        switch action {
        case .viewDidLoad:
            loadAvailableFiles()
            await loadExistingDatabases()
        case .openDatabase(let databaseInfo):
            mainCoordinator?.openNodeView(graphId: databaseInfo.id)
        case .selectGraphFile(let name):
            state.selectedGraphFile = name
        case .processGraphFile:
            await processGraphFile()
        case .closeError:
            state.errorMessage = nil
        }
    }
    
    private func loadAvailableFiles() {
        let urls = Bundle.main.urls(forResourcesWithExtension: "graphml", subdirectory: nil) ?? []
        let fileNames = urls.map({ $0.deletingPathExtension().lastPathComponent }).sorted()
        state.graphFiles = fileNames
        state.selectedGraphFile = fileNames.first ?? ""
    }
    
    private func loadExistingDatabases() async {
        do {
            let graphs = try await graphService.getGraphs()
            state.existingDatabases = graphs.map({
                DatabaseInfo(id: $0.id)
            })
        } catch {
            state.errorMessage = error.localizedDescription
        }
    }
    
    private func processGraphFile() async {
        state.processing = true
        
        let fileName = state.selectedGraphFile
        
        let url = Bundle.main.url(forResource: fileName, withExtension: "graphml")!
        
        do {
            try await graphService.loadGraph(url: url, graphId: fileName)
        } catch {
            state.errorMessage = error.localizedDescription
        }

        state.processing = false
        await loadExistingDatabases()
    }
}
