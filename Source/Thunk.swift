//
//  Thunk.swift
//  SwiftRedux
//
//  Created by Robert Brown on 11/13/15.
//  Copyright © 2015 Robert Brown. All rights reserved.
//

import Foundation

public struct AsyncAction<T>: Action {
    public typealias StateFetcher = Void->T
    public typealias AsyncActionFunction = (Dispatch,StateFetcher)->Void
    
    public let type: String
    public let payload: AnyObject? = nil
    public let meta: AnyObject? = nil
    public let error: Bool = false
    public let function: AsyncActionFunction
    
    public init(type: String, function: AsyncActionFunction) {
        self.type = type
        self.function = function
    }
}

public struct Thunk<T> {
    public static func middleware() -> Middleware<T> {
        return Middleware { (dispatch, currentState) -> Dispatch -> Dispatch in
            { next in { action in
                guard let asyncAction = action as? AsyncAction<T> else {
                    return (try? next(action)) ?? action
                }
                asyncAction.function(dispatch, currentState)
                return action
                }
            }
        }
    }
}
