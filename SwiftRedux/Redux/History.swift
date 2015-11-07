//
//  HistoryReducer.swift
//  SwiftRedux
//
//  Created by Robert Brown on 11/6/15.
//  Copyright © 2015 Robert Brown. All rights reserved.
//

import Foundation

public enum HistoryAction: String {
    case Undo = "HistoryUndo"
    case Redo = "HistoryRedo"
    
    public static func createUndo() -> Action {
        return BasicAction(type: HistoryAction.Undo.rawValue)
    }
    
    public static func createRedo() -> Action {
        return BasicAction(type: HistoryAction.Redo.rawValue)
    }
}

public struct History<T> {
    public let current: T
    public let past: [T]
    public let future: [T]
    
    public init(current: T, past: [T] = [T](), future: [T] = [T]()) {
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
        guard let newCurrent = past.first else { return self }
        let newFuture = [current] + future
        let newPast = Array(past[1..<past.count])
        return History(current: newCurrent, past: newPast, future: newFuture)
    }
    
    public func redo() -> History<T> {
        guard let newCurrent = future.first else { return self }
        let newFuture = Array(future[1..<future.count])
        let newPast = [current] + past
        return History(current: newCurrent, past: newPast, future: newFuture)
    }
    
    public func add(newCurrent: T) -> History<T> {
        let newPast = [current] + past
        return History(current: newCurrent, past: newPast, future: [])
    }
}

public func historyReducerCreator<T: Equatable>(reducer: Reducer<T>) -> Reducer<History<T>> {
    return Reducer { (state, action) in
        // If this is a history action, change the history.
        if let actionType = HistoryAction(rawValue: action.type) {
            switch actionType {
            case .Undo:
                return state.undo()
            case .Redo:
                return state.redo()
            }
        }
        // Otherwise, perform the wrapped reducer and update the history as needed.
        else {
            let new = try reducer.reduce(state.current, action: action)
            if new == state.current {
                return state
            }
            return state.add(new)
        }
    }
}
