//
//  AppDelegate.swift
//  SwiftRedux
//
//  Created by Robert Brown on 10/28/15.
//  Copyright © 2015 Robert Brown. All rights reserved.
//

import UIKit

let appStateReducer = Reducer<AppState> { state, action in
    let counter = try counterReducer.reduce(state.counter, action: action)
    let todos = try toDoReducer.reduce(state.todos, action: action)
    let (randomNumberLoading, randomNumber) = try randomReducer.reduce((state.randomNumberLoading, state.randomNumber), action: action)
    
    return AppState(counter: counter, todos: todos, randomNumber: randomNumber, randomNumberLoading: randomNumberLoading)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    typealias State = History<AppState>
    
    var window: UIWindow?
    var store: Store<State>?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let rootReducer = historyReducerCreator(appStateReducer)
        let middlewares: [Middleware<State>] = [Logger.middleware(), Thunk.middleware()]
        let sessionID = "A session ID"
        
        // Sets up the store
        // When an action is dispatched, the StoreEnhancers work in this order:
        // 1. Middleware
        // 2. Persist
        // 3. Store
        let storeCreator =
        StoreCreator<State>(function: Store<State>.createStore)
        |> Persist.apply(sessionID, persister: appStatePersister)
        |> Middleware.apply(middlewares)
        
        let initialState = History(state: AppState(counter: 0, todos: [], randomNumber: 0))
        let store = storeCreator.createStore(reducer: rootReducer, initialState: initialState)
        let notifier = Notifier(store: store)
        
        if let tabController = window?.rootViewController as? UITabBarController {
            
            for viewController in tabController.viewControllers ?? [] {
                var target: ReduxTarget?
                if let viewController = viewController as? ReduxTarget {
                    target = viewController
                }
                else if let navController = viewController as? UINavigationController {
                    if let viewController = navController.topViewController as? ReduxTarget {
                        target = viewController
                    }
                }
                target?.store = store
                target?.notifier = notifier
            }
        }
        
        return true
    }
}

