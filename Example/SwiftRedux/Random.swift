//
//  Random.swift
//  SwiftRedux
//
//  Created by Robert Brown on 11/14/15.
//  Copyright © 2015 Robert Brown. All rights reserved.
//

import Foundation

public enum RandomAction: String {
    case RandomNumber = "RandomNumber"
    case RandomNumberLoading = "RandomNumberLoading"
}

public struct RandomActionCreater {
    public static func randomNumber(number: Int) -> Action {
        return BasicAction(type: RandomAction.RandomNumber.rawValue, payload: number)
    }
    
    public static func randomNumberLoading(loading: Bool) -> Action {
        return BasicAction(type: RandomAction.RandomNumberLoading.rawValue, payload: loading)
    }
}

let randomReducer = Reducer<(Bool,Int)> { state, action in
    guard let actionType = RandomAction(rawValue: action.type) else { return state }
    let (oldLoad, oldNum) = state
    
    switch actionType {
    case .RandomNumber:
        guard let number = action.payload as? Int else { break }
        return (oldLoad, number)
    case .RandomNumberLoading:
        guard let loading = action.payload as? Bool else { break }
        return (loading, oldNum)
    }
    
    return state
}
