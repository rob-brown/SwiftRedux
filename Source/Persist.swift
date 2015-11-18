//
//  Persist.swift
//  SwiftRedux
//
//  Created by Robert Brown on 11/11/15.
//  Copyright © 2015 Robert Brown. All rights reserved.
//

import Foundation

public typealias SessionID = String

public struct Persister<T> {
    public typealias State = T
    public typealias StateSerializer = ((SessionID, State, Action)throws->())
    public typealias StateDeserializer = ((SessionID)throws->(State))
    
    public let stateSerializer: StateSerializer
    public let stateDeserializer: StateDeserializer
    
    public init(stateSerializer: StateSerializer, stateDeserializer: StateDeserializer) {
        self.stateSerializer = stateSerializer
        self.stateDeserializer = stateDeserializer
    }
}

public struct Persist<T> {
    public static func apply(sessionID: SessionID, persister: Persister<T>) -> StoreEnhancer<T,T> {
        let queue = dispatch_queue_create("redux.swift.persist", DISPATCH_QUEUE_SERIAL)
        
        return StoreEnhancer<T,T> { (next: StoreCreator<T>) in
            return StoreCreator<T> { (reducer: Reducer<T>, initialState: T) in
                let state: T
                do {
                    state = try persister.stateDeserializer(sessionID)
                }
                catch {
                    NSLog("Error restoring state. Falling back to initial state.")
                    state = initialState
                }
                
                let store = next.createStore(reducer: reducer, initialState: state)
                let dispatcher = store.dispatchFunction()
                store.replaceDispatchFunction { action in
                    try dispatcher(action)
                    let newState = store.currentState()
                    
                    dispatch_async(queue) {
                        do {
                            try persister.stateSerializer(sessionID, newState, action)
                        }
                        catch {
                            NSLog("ERROR: Unable to persist state.")
                        }
                    }
                    
                    return action
                }
                
                return store
            }
        }
    }
}
