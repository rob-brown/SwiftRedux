//
//  Counter.swift
//  SwiftRedux
//
//  Created by Robert Brown on 10/29/15.
//  Copyright © 2015 Robert Brown. All rights reserved.
//

import Foundation

public enum CounterAction: String {
    case Increment = "Increment"
    case Decrement = "Decrement"
}

public func counterReducer(state: State, action: Action) throws -> State {
    guard let counter = state as? Int else { return state }
    guard let actionType = CounterAction(rawValue: action.type) else { return state }
    
    switch actionType {
    case .Increment:
        return counter + 1
    case .Decrement:
        return counter - 1
    }
}
