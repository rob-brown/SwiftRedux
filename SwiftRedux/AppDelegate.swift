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
        let middlewares: [Middleware<State>] = [Thunk<State>.middleware()]
        let createStore = StoreCreator<State>(function: Store<State>.createStore)
        let sessionID = "A session ID"
        
        // TODO: Create a pipe operator to clean up function composition.
        
        let persistStoreCreator = Persist.apply(sessionID, persister: appStatePersister).enhance(createStore)
        let augmentedCreater = Middleware.apply(middlewares).enhance(persistStoreCreator)
        
        let initialState = History(state: AppState(counter: 0, todos: [], randomNumber: 0))
        let store = augmentedCreater.createStore(reducer: rootReducer, initialState: initialState)
        let notifier = Notifier(store: store)
        
        if let tabController = window?.rootViewController as? UITabBarController {
            
            if let viewController = tabController.viewControllers![0] as? CounterViewController {
                viewController.store = store
                viewController.notifier = notifier
            }
            
            if let navController = tabController.viewControllers![1] as? UINavigationController {
                if let viewController = navController.topViewController as? ToDoViewController {
                    viewController.store = store
                    viewController.notifier = notifier
                }
            }
            
            if let viewController = tabController.viewControllers![2] as? AsyncViewController {
                viewController.store = store
                viewController.notifier = notifier
            }
        }
        
        return true
    }
}

