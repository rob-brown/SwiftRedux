//
//  StoreCreator.swift
//  SwiftRedux
//
//  Created by Robert Brown on 11/11/15.
//  Copyright © 2015 Robert Brown. All rights reserved.
//

import Foundation

public struct StoreCreator<T> {
    public typealias State = T
    public typealias StoreCreatorFunction = (Reducer<State>,State)->Store<State>
    
    let function: StoreCreatorFunction
    
    public init(function: StoreCreatorFunction) {
        self.function = function
    }
    
    public func createStore(reducer reducer: Reducer<T>, initialState: State) -> Store<State> {
        return function(reducer, initialState)
    }
}
