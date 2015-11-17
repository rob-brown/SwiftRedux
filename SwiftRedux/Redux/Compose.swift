//
//  Compose.swift
//  SwiftRedux
//
//  Created by Robert Brown on 11/17/15.
//  Copyright © 2015 Robert Brown. All rights reserved.
//

import Foundation

infix operator |> { precedence 50 associativity left }

public func |> <A,Z>(lhs: A, rhs: A -> Z) -> Z {
    return rhs(lhs)
}
