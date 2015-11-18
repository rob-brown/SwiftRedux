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
    public let randomNumber: Int
    public let randomNumberLoading: Bool
    
    public init(counter: Int, todos: [ToDo], randomNumber: Int, randomNumberLoading: Bool = false) {
        self.counter = counter
        self.todos = todos
        self.randomNumber = randomNumber
        self.randomNumberLoading = randomNumberLoading
    }
}

public func ==(lhs: AppState, rhs: AppState) -> Bool {
    return (lhs.counter == rhs.counter &&
        lhs.todos == rhs.todos &&
        lhs.randomNumber == rhs.randomNumber &&
        lhs.randomNumberLoading == rhs.randomNumberLoading)
}

extension AppState: Equatable {}

public struct AppStateError: ErrorType {
    public let message: String
    
    public init(_ message: String) {
        self.message = message
    }
}

public func appStateSerializer(sessionID: SessionID, state: History<AppState>, action: Action) throws {
    guard let path = saveFilePath(sessionID) else {
        throw AppStateError("Unable to find save file.")
    }
    let data = try stateToJSON(state.current.state)
    data.writeToFile(path, atomically: true)
}

public func appStateDeserializer(sessionID: SessionID) throws -> History<AppState> {
    guard let path = saveFilePath(sessionID), data = NSData(contentsOfFile: path) else {
        throw AppStateError("Unable to read save file.")
    }
    let state = try jsonToState(data)
    return History(state: state)
}

let appStatePersister = Persister<History<AppState>>(stateSerializer: appStateSerializer, stateDeserializer: appStateDeserializer)

private func saveFilePath(sessionID: SessionID) -> String? {
    guard let dir = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true).first else { return nil }
    let filename = sessionID + ".json"
    return (dir as NSString).stringByAppendingPathComponent(filename)
}

private func stateToJSON(state: AppState) throws -> NSData {
    var todos = [[String:AnyObject]]()
    
    for todo in state.todos {
        todos.append([
            "text": todo.text,
            "completed": todo.completed,
            ])
    }
    let dict: [String:AnyObject] = [
        "counter": state.counter,
        "todos": todos,
        "randomNumber": state.randomNumber,
    ]
    
    return try NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions())
}

private func jsonToState(data: NSData) throws -> AppState {
    let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
    
    guard let counter = json["counter"] as? Int, todoDicts = json["todos"] as? [[String:AnyObject]], randomNumber = json["randomNumber"] as? Int else {
        throw AppStateError("Unable to parse save file.")
    }
    
    var todos = [ToDo]()
    
    for todoDict in todoDicts {
        if let text = todoDict["text"] as? String, completed = todoDict["completed"] as? Bool {
            todos.append(ToDo(text: text, completed: completed))
        }
    }
    
    return AppState(counter: counter, todos: todos, randomNumber: randomNumber)
}
