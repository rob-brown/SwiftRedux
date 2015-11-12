//
//  Notifier.swift
//  SwiftRedux
//
//  Created by Robert Brown on 11/5/15.
//  Copyright © 2015 Robert Brown. All rights reserved.
//

import Foundation

public class Notifier {
    public let store: Store<History<AppState>>
    public let stateNotifier: DiffNotifier<AppState>
    public let counterNotifier: DiffNotifier<Int>
    public let todoNotifier: DiffListNotifier<ToDo>
    public let canUndoNotifier: DiffNotifier<Bool>
    public let canRedoNotifier: DiffNotifier<Bool>
    private var unsubscriber: Unsubscriber?
    
    public init(store: Store<History<AppState>>) {
        self.store = store
        self.stateNotifier = DiffNotifier(store.currentState().current.state)
        self.counterNotifier = DiffNotifier(store.currentState().current.state.counter)
        self.todoNotifier = DiffListNotifier(store.currentState().current.state.todos)
        self.canUndoNotifier = DiffNotifier(store.currentState().canUndo())
        self.canRedoNotifier = DiffNotifier(store.currentState().canRedo())
        self.unsubscriber = store.subscribe(self.stateChanged)
    }
    
    deinit {
        unsubscriber?()
    }
    
    private func stateChanged() {
        let state = store.currentState()
        stateNotifier.currentState = state.current.state
        counterNotifier.currentState = state.current.state.counter
        todoNotifier.currentState = state.current.state.todos
        canUndoNotifier.currentState = state.canUndo()
        canRedoNotifier.currentState = state.canRedo()
    }
}
