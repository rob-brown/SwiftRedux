//
//  Notifier.swift
//  SwiftRedux
//
//  Created by Robert Brown on 11/5/15.
//  Copyright © 2015 Robert Brown. All rights reserved.
//

import Foundation

public class Notifier {
    public let store: Store<AppState>
    private let counterNotifier: DiffNotifier<Int>
    private let todoNotifier: DiffListNotifier<ToDo>
    private var unsubscriber: Unsubscriber?
    
    public init(store: Store<AppState>) {
        self.store = store
        self.counterNotifier = DiffNotifier(initialState: store.currentState().counter)
        self.todoNotifier = DiffListNotifier(initialState: store.currentState().todos)
        self.unsubscriber = store.subscribe(self.stateChanged)
    }
    
    deinit {
        unsubscriber?()
    }
    
    public func subscribeToCounter(listener: ((Int)->())) -> DiffNotifier<Int>.Unsubscriber {
        return counterNotifier.subscribe(listener)
    }
    
    public func subscribeToToDos(listener: (([ToDo])->())) -> DiffListNotifier<ToDo>.Unsubscriber {
        return todoNotifier.subscribe(listener)
    }
    
    private func stateChanged() {
        let state = store.currentState()
        counterNotifier.currentState = state.counter
        todoNotifier.currentState = state.todos
    }
}

public class DiffNotifier<T: Equatable> {
    public typealias Listener = (T)->()
    public typealias Unsubscriber = ()->()
    
    private var listeners = [String:Listener]()
    private var currentState: T {
        didSet {
            if currentState != oldValue {
                listeners.forEach { $0.1(currentState) }
            }
        }
    }
    
    public init(initialState: T) {
        currentState = initialState
    }
    
    public func subscribe(listener: Listener) -> Unsubscriber {
        let key = NSUUID().UUIDString
        listeners[key] = listener
        listener(currentState)
        
        return {
            self.listeners.removeValueForKey(key)
        }
    }
}

public class DiffListNotifier<T: Equatable> {
    public typealias Listener = ([T])->()
    public typealias Unsubscriber = ()->()
    
    private var listeners = [String:Listener]()
    private var currentState: [T] {
        didSet {
            if currentState != oldValue {
                listeners.forEach { $0.1(currentState) }
            }
        }
    }
    
    public init(initialState: [T]) {
        currentState = initialState
    }
    
    public func subscribe(listener: Listener) -> Unsubscriber {
        let key = NSUUID().UUIDString
        listeners[key] = listener
        listener(currentState)
        
        return {
            self.listeners.removeValueForKey(key)
        }
    }
}
