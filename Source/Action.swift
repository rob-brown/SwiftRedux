//
//  Action.swift
//  SwiftRedux
//
//  Created by Robert Brown on 10/28/15.
//  Copyright © 2015 Robert Brown. All rights reserved.
//

import Foundation

public protocol Action {
    var type: String { get }
    var payload: AnyObject? { get }
    var meta: AnyObject? { get }
    var error: Bool { get }
}

public struct BasicAction: Action {
    public let type: String
    public let payload: AnyObject?
    public let meta: AnyObject?
    public let error: Bool
    
    public init(type: String, payload: AnyObject? = nil, meta: AnyObject? = nil, error: Bool = false) {
        self.type = type
        self.payload = payload
        self.meta = meta
        self.error = error
    }
}
