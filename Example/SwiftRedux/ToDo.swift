//
//  ToDo.swift
//  SwiftRedux
//
//  Created by Robert Brown on 10/29/15.
//  Copyright © 2015 Robert Brown. All rights reserved.
//

import Foundation

public struct ToDo {
    public let text: String
    public let completed: Bool
    
    public init(text: String, completed: Bool = false) {
        self.text = text
        self.completed = completed
    }
    
    public init(original: ToDo, text: String? = nil, completed: Bool? = nil) {
        self.text = text ?? original.text
        self.completed = completed ?? original.completed
    }
}

public func ==(lhs: ToDo, rhs: ToDo) -> Bool {
    return lhs.text == rhs.text && lhs.completed == rhs.completed
}

extension ToDo: Equatable {}

public enum ToDoAction: String {
    case CreateToDo = "CreateToDo"
    case MarkCompleted = "MarkCompleted"
    case Restart = "Restart"
}

public struct ToDoActionCreater {
    public static func create(text: String) -> Action {
        return BasicAction(type: ToDoAction.CreateToDo.rawValue, payload: text)
    }
    
    public static func complete(index: Int) -> Action {
        return BasicAction(type: ToDoAction.MarkCompleted.rawValue, payload: index)
    }
    
    public static func restart(index: Int) -> Action {
        return BasicAction(type: ToDoAction.Restart.rawValue, payload: index)
    }
}

let toDoReducer = Reducer<[ToDo]> { state, action in
    guard let actionType = ToDoAction(rawValue: action.type) else { return state }
    
    switch actionType {
    case .CreateToDo:
        guard let text = action.payload as? String else { break }
        let todo = ToDo(text: text)
        return [todo] + state
    case .MarkCompleted:
        guard let index = action.payload as? Int else { break }
        var mutableTodos = state
        let todo = mutableTodos.removeAtIndex(index)
        let completed = ToDo(original: todo, completed: true)
        return mutableTodos + [completed]
    case .Restart:
        guard let index = action.payload as? Int else { break }
        var mutableTodos = state
        let todo = mutableTodos.removeAtIndex(index)
        let restarted = ToDo(original: todo, completed: false)
        return [restarted] + mutableTodos
    }
    
    return state
}
