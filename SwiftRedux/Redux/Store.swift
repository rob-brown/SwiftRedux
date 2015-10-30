//
//  Store.swift
//  SwiftRedux
//
//  Created by Robert Brown on 10/28/15.
//  Copyright © 2015 Robert Brown. All rights reserved.
//

import Foundation

public enum InternalAction: String {
    case Init = "SwiftRedux/Init"
}

public typealias State = AnyObject
public typealias Listener = Void->Void
public typealias Unsubscriber = Void->Void
public typealias Dispatch = Action throws->Action
public typealias StoreCreator = (Reducer,State)->Store
public typealias StoreEnhancer = StoreCreator->StoreCreator

public protocol Store {
    func dispatch(action: Action) throws -> Action
    func dispatchFunction() -> Dispatch
    func currentState() -> State
    func replaceReducer(reducer: Reducer)
    func subscribe(listener: Listener) -> Unsubscriber
    
    /// Internal use only!
    /// Creates a new, identical store, except with a new reducer.
    /// Do not mutate the called store.
    func replaceDispatchFunction(dispatcher: Dispatch)
}

public class BasicStore: Store {
    private var listeners: [String:Listener]
    private var rootReducer: Reducer
    private var state: State
    private var isDispatching: Bool = false
    private lazy var dispatcher: Dispatch = {
        return { action in
            guard self.isDispatching == false else {
                let info = [NSLocalizedDescriptionKey: "Can't dispatch in a reducer."]
                throw NSError(domain: __FILE__, code: __LINE__, userInfo: info)
            }
            do {
                self.isDispatching = true
                self.state = try self.rootReducer(self.state, action)
            }
            catch let error {
                // defer isn't working, so I have to catch and rethrow.
                NSLog("Reducer threw '\(error)'")
                self.isDispatching = false
                throw error
            }
            self.isDispatching = false
            self.notifyListeners()
            return action
        }
    }()
    
    private init(reducer: Reducer, initialState: State, dispatcher: Dispatch? = nil, listeners: [String:Listener] = [:]) {
        self.rootReducer = reducer
        self.state = initialState
        self.listeners = listeners
        if let dispatcher = dispatcher {
            self.dispatcher = dispatcher
        }
    }
    
    public class func createStore(reducer: Reducer, initialState: State) -> Store {
        let store = BasicStore(reducer: reducer, initialState: initialState)
        store.dispatchInit()
        return store
    }
    
    public func currentState() -> State {
        return state
    }
    
    public func replaceDispatchFunction(dispatcher: Dispatch) {
        self.dispatcher = dispatcher
    }
    
    public func dispatch(action: Action) throws -> Action {
        // ???: Should this ensure the dispatch happens on a particular queue?
        return try dispatcher(action)
    }
    
    public func dispatchFunction() -> Dispatch {
        return dispatcher
    }
    
    public func replaceReducer(reducer: Reducer) {
        rootReducer = reducer
        dispatchInit()
    }
    
    public func subscribe(listener: Listener) -> Unsubscriber {
        // Associates a unique key with each listener for easy removal.
        let key = NSUUID().UUIDString
        listeners[key] = listener
        return {
            self.listeners.removeValueForKey(key)
        }
    }
    
    private func dispatchInit() {
        let action = BasicAction(type: InternalAction.Init.rawValue)
        _ = try? dispatch(action)
    }
    
    private func notifyListeners() {
        for (_, listener) in listeners {
            listener()
        }
    }
}
