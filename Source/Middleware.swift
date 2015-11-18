//
//  Middleware.swift
//  SwiftRedux
//
//  Created by Robert Brown on 10/28/15.
//  Copyright © 2015 Robert Brown. All rights reserved.
//

import Foundation

public struct Middleware<T> {
    public typealias State = T
    public typealias StateFetcher = Void->State
    public typealias MiddlewareAPI = (dispatch: Dispatch, currentState: StateFetcher)
    public typealias MiddlewareFunction = MiddlewareAPI->Dispatch->Dispatch
    
    private let function: MiddlewareFunction
    
    public init(function: MiddlewareFunction) {
        self.function = function
    }
    
    public static func apply(middlewares: [Middleware<T>]) -> StoreEnhancer<T,T> {
        return StoreEnhancer<T,T> { (next: StoreCreator<T>) in
            return StoreCreator<T> { (reducer: Reducer<T>, initialState: T) in
                let store = next.createStore(reducer: reducer, initialState: initialState)
                let dispatch = store.dispatchFunction()
                let middlewareAPI = (dispatch: dispatch, currentState: store.currentState)
                let newDispatch = middlewares.reverse().reduce(dispatch) { intermediateDispatch, middleware in
                    return middleware.function(middlewareAPI)(intermediateDispatch)
                }
                store.replaceDispatchFunction(newDispatch)
                
                return store
            }
        }
    }
}
