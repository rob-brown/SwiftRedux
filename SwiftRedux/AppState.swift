//
//  AppState.swift
//  SwiftRedux
//
//  Created by Robert Brown on 10/30/15.
//  Copyright © 2015 Robert Brown. All rights reserved.
//

import Foundation

public class AppState {
    public let counter: Int
    public let todos: [ToDo]
    
    public init(counter: Int, todos: [ToDo]) {
        self.counter = counter
        self.todos = todos
    }
}

public func ==(lhs: AppState, rhs: AppState) -> Bool {
    return lhs.counter == rhs.counter && lhs.todos == rhs.todos
}

extension AppState: Equatable {}
