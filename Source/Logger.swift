//
//  Logger.swift
//  SwiftRedux
//
//  Created by Robert Brown on 11/17/15.
//  Copyright © 2015 Robert Brown. All rights reserved.
//

import Foundation

public struct Logger<T> {
    public static func middleware() -> Middleware<T> {
        return Middleware { (dispatch, currentState) -> Dispatch -> Dispatch in
            { next in { action in
                NSLog("Action:\n  Type: \(action.type)\n  Error?: \(action.error)\n  Payload: \(action.payload)\n  Meta: \(action.meta)")
                return try next(action)
                }
            }
        }
    }
}
