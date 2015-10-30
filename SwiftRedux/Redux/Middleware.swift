//
//  Middleware.swift
//  SwiftRedux
//
//  Created by Robert Brown on 10/28/15.
//  Copyright © 2015 Robert Brown. All rights reserved.
//

import Foundation

public typealias Middleware = MiddlewareAPI->Dispatch->Dispatch
public typealias StateFetcher = Void->State
public typealias MiddlewareAPI = (dispatch: Dispatch, currentState: StateFetcher)

public func applyMiddleware(middlewares: [Middleware]) -> StoreEnhancer {
    return { (next: StoreCreator) in
        return { (reducer: Reducer, initialState: State) in
            let store = next(reducer, initialState)
            let dispatch = store.dispatchFunction()
            let middlewareAPI = (dispatch: dispatch, currentState: store.currentState)
            let newDispatch = middlewares.reverse().reduce(dispatch) { intermediateDispatch, middleware in
                return middleware(middlewareAPI)(intermediateDispatch)
            }
            store.replaceDispatchFunction(newDispatch)
            
            return store
        }
    }
}
