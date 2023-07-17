//
//  AnyViewModel.swift
//
//
//  Created by Kamil Zaborowski on 28/01/2023.
//  Copyright © 2023 Kamil Zaborowski. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

public typealias AnyViewModelOf<VM: ViewModel> = AnyViewModel<VM.State, VM.Action>

@dynamicMemberLookup
public final class AnyViewModel<State, Action>: ObservableObject {

    private let wrappedState: () -> State
    private let wrappedTrigger: (Action) -> Void
    
    public var state: State {
        wrappedState()
    }

    public func trigger(_ action: Action) {
        wrappedTrigger(action)
    }
    
    public subscript<Value>(dynamicMember keyPath: KeyPath<State, Value>) -> Value {
        state[keyPath: keyPath]
    }
    
    private lazy var viewModelTypeIdentifier: String = String(describing: self)

    private var cancelBag = Set<AnyCancellable>()
    
    public init<V: ViewModel>(_ viewModel: V) where V.State == State, V.Action == Action {
        self.wrappedState = { viewModel.state }
        self.wrappedTrigger = viewModel.trigger
        
        viewModel.objectWillChange
            .sink { [weak self] _ in
                if !Thread.isMainThread {
                    assertionFailure("objectWillChange was called from background thread. Add @MainActor to async function that updates state or use MainActor.run { }")
                }
                self?.objectWillChange.send()
            }.store(in: &cancelBag)
    }
}

public extension AnyViewModel {
    func binding<Value>(_ keyPath: KeyPath<State, Value>, input: ((Value)->Action)?) -> Binding<Value> {
        Binding {
            self.state[keyPath: keyPath]
        } set: { newValue in
            if let input {
                self.trigger(input(newValue))
            }
        }
    }
}
