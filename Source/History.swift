//
//  HistoryReducer.swift
//  SwiftRedux
//
//  Created by Robert Brown on 11/6/15.
//  Copyright © 2015 Robert Brown. All rights reserved.
//

import Foundation

public struct HistoryError: ErrorType {
    public let message: String
    
    public init(message: String = "") {
        self.message = message
    }
}

public enum HistoryAction: String {
    case Undo = "HistoryUndo"
    case Redo = "HistoryRedo"
    case JumpBack = "HistoryJumpBack"
    case JumpForward = "HistoryJumpForward"
    
    public static func createUndo() -> Action {
        return BasicAction(type: HistoryAction.Undo.rawValue)
    }
    
    public static func createRedo() -> Action {
        return BasicAction(type: HistoryAction.Redo.rawValue)
    }
    
    public static func jumpBack(n: Int) -> Action {
        return BasicAction(type: HistoryAction.JumpBack.rawValue, payload: n)
    }
    
    public static func jumpForward(n: Int) -> Action {
        return BasicAction(type: HistoryAction.JumpForward.rawValue, payload: n)
    }
}

public struct HistoryItem<T> {
    public let action: Action
    public let state: T
    
    public init(action: Action, state: T) {
        self.action = action
        self.state = state
    }
}

public struct History<T> {
    public let current: HistoryItem<T>
    public let past: [HistoryItem<T>]
    public let future: [HistoryItem<T>]
    
    public init(state: T) {
        let action = BasicAction(type: InternalAction.Init.rawValue)
        let item = HistoryItem(action: action, state: state)
        self.current = item
        self.past = [HistoryItem<T>]()
        self.future = [HistoryItem<T>]()
    }
    
    public init(current: HistoryItem<T>, past: [HistoryItem<T>] = [HistoryItem<T>](), future: [HistoryItem<T>] = [HistoryItem<T>]()) {
        self.current = current
        self.past = past
        self.future = future
    }
    
    public func canUndo() -> Bool {
        return past.count > 0
    }
    
    public func canRedo() -> Bool {
        return future.count > 0
    }
    
    public func undo() -> History<T> {
        guard let newHistory = try? jumpBack(1) else { return self }
        return newHistory
    }
    
    public func redo() -> History<T> {
        guard let newHistory = try? jumpForward(1) else { return self }
        return newHistory
    }
    
    public func jumpBack(steps: Int) throws -> History<T> {
        guard steps < past.count && steps > 0 else {
            throw HistoryError(message: "Invalid number of steps: \(steps)")
        }
        let newPast = past.drop(steps)
        let newCurrent = past[steps - 1]
        let newFuture = past.take(steps - 1).reverse() + [current] + future
        return History(current: newCurrent, past: newPast, future: newFuture)
    }
    
    public func jumpForward(steps: Int) throws -> History<T> {
        guard steps < future.count && steps > 0 else {
            throw HistoryError(message: "Invalid number of steps: \(steps)")
        }
        let newFuture = future.drop(steps)
        let newCurrent = future[steps - 1]
        let newPast = future.take(steps - 1).reverse() + [current] + past
        return History(current: newCurrent, past: newPast, future: newFuture)
    }
    
    public func add(newCurrent: HistoryItem<T>) -> History<T> {
        let newPast = [current] + past
        return History(current: newCurrent, past: newPast, future: [])
    }
}

public func historyReducerCreator<T: Equatable>(reducer: Reducer<T>) -> Reducer<History<T>> {
    return Reducer { (state, action) in
        // If this is a history action, change the history.
        if let action = action as? BasicAction, actionType = HistoryAction(rawValue: action.type) {
            switch actionType {
            case .Undo:
                return state.undo()
            case .Redo:
                return state.redo()
            case .JumpBack:
                guard let steps = action.payload as? Int else {
                    throw HistoryError(message: "No steps given.")
                }
                return try state.jumpBack(steps)
            case .JumpForward:
                guard let steps = action.payload as? Int else {
                    throw HistoryError(message: "No steps given.")
                }
                return try state.jumpForward(steps)
            }
        }
        // Otherwise, perform the wrapped reducer and update the history as needed.
        else {
            let old = state.current.state
            let new = try reducer.reduce(old, action: action)
            if new == old {
                return state
            }
            return state.add(HistoryItem(action: action, state: new))
        }
    }
}
