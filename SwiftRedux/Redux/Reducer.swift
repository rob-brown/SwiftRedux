//
//  Reducer.swift
//  SwiftRedux
//
//  Created by Robert Brown on 10/28/15.
//  Copyright © 2015 Robert Brown. All rights reserved.
//

import Foundation

public class Reducer<T> {
    public typealias State = T
    public typealias ReducerFunction = (State,Action)throws->State
    
    private let reducerFunction: ReducerFunction
    
    public init(reducerFunction: ReducerFunction) {
        self.reducerFunction = reducerFunction
    }
    
    public func reduce(state: State, action: Action) throws -> State {
        return try reducerFunction(state, action)
    }
}
