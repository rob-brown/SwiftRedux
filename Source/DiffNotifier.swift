//
//  DiffNotifier.swift
//  SwiftRedux
//
//  Created by Robert Brown on 11/6/15.
//  Copyright © 2015 Robert Brown. All rights reserved.
//

import Foundation

public class DiffNotifier<T: Equatable> {
    public typealias Listener = (T)->()
    public typealias Unsubscriber = ()->()
    public var currentState: T {
        didSet {
            if currentState != oldValue {
                listeners.forEach { $0.1(currentState) }
            }
        }
    }
    private var listeners = [String:Listener]()
    
    public init(_ initialState: T) {
        currentState = initialState
    }
    
    public func subscribe(listener: Listener) -> Unsubscriber {
        let key = NSUUID().UUIDString
        listeners[key] = listener
        listener(currentState)
        
        return {
            self.listeners.removeValueForKey(key)
        }
    }
}

public class DiffListNotifier<T: Equatable> {
    public typealias Listener = ([T])->()
    public typealias Unsubscriber = ()->()
    public var currentState: [T] {
        didSet {
            if currentState != oldValue {
                listeners.forEach { $0.1(currentState) }
            }
        }
    }
    private var listeners = [String:Listener]()
    
    public init(_ initialState: [T]) {
        currentState = initialState
    }
    
    public func subscribe(listener: Listener) -> Unsubscriber {
        let key = NSUUID().UUIDString
        listeners[key] = listener
        listener(currentState)
        
        return {
            self.listeners.removeValueForKey(key)
        }
    }
}
