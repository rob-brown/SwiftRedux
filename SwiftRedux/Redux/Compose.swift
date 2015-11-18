//
//  Compose.swift
//  SwiftRedux
//
//  Created by Robert Brown on 11/17/15.
//  Copyright © 2015 Robert Brown. All rights reserved.
//

import Foundation

infix operator |> { precedence 50 associativity left }

public func |> <T,U>(lhs: StoreCreator<T>, rhs: StoreEnhancer<T,U>) -> StoreCreator<U> {
    return rhs.enhance(lhs)
}
