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

public let counterReducer = Reducer<Int> { state, action in
    guard let actionType = CounterAction(rawValue: action.type) else { return state }
    
    switch actionType {
    case .Increment:
        return state + 1
    case .Decrement:
        return state - 1
    }
}
