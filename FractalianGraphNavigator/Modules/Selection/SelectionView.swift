//
// SelectionView.swift
// FractalianGraphNavigator
//
// Created by Kamil Zaborowski on 14/07/2023
// Copyright © 2023 Kamil Zaborowski. All rights reserved.
//

import SwiftUI
import ModularModel
import GraphService

struct SelectionView: View {
    @StateObject var viewModel: AnyViewModelOf<SelectionViewModel>
    
    init(container: Container) {
        _viewModel = SelectionViewModel(container: container).eraseToStateObject()
    }
    
    var body: some View {
        VStack {
            HStack {
                Picker("File", selection: viewModel.binding(\.selectedGraphFile, input: { .selectGraphFile($0) })) {
                    ForEach(viewModel.graphFiles, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.menu)
                Spacer()
                Button("Process") {
                    viewModel.trigger(.processGraphFile)
                }
                .buttonStyle(.bordered)
            }
            .padding(8)
            .disabled(viewModel.processing)
            
            HStack {
                if viewModel.processing {
                    Text("Processing \(viewModel.selectedGraphFile ?? "")")
                    ProgressView()
                        .padding()
                }
            }.frame(height: 100)
            
            Text("Existing graphs")
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.existingDatabases) { databaseInfo in
                        Button(databaseInfo.id) {
                            viewModel.trigger(.openDatabase(databaseInfo))
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
        .alert(viewModel.errorMessage ?? "",
               isPresented: viewModel.binding(\.errorVisible, input: { _ in .closeError })) {
            Button("Cancel", role: .cancel) {}
        }
        .onAppear {
            viewModel.trigger(.viewDidLoad)
        }
    }
}

struct SelectionView_Previews: PreviewProvider {
    static var container = PreviewContainerFactory.build()
    
    static var previews: some View {
        SelectionView(container: container)
            .frame(minWidth: 300, minHeight: 500)
    }
}
