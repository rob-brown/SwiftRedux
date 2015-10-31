//
//  AppDelegate.swift
//  SwiftRedux
//
//  Created by Robert Brown on 10/28/15.
//  Copyright © 2015 Robert Brown. All rights reserved.
//

import UIKit

public func rootReducer(state: State, action: Action) throws -> State {
    guard let state = state as? AppState else {
        let info = [NSLocalizedDescriptionKey: "Reducer expected AppState"]
        throw NSError(domain: __FILE__, code: __LINE__, userInfo: info)
    }
    guard let counter = (try? counterReducer(state.counter, action: action)) as? Int else { return state }
    guard let todos = (try? toDoReducer(state.todos, action: action)) as? [ToDo] else { return state }
    
    return AppState(counter: counter, todos: todos)
}



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var store: Store?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let initialState = AppState(counter: 0, todos: [])
        let augmentedCreater = applyMiddleware([])(BasicStore.createStore)
        let store = augmentedCreater(rootReducer, initialState)
        
        if let tabController = window?.rootViewController as? UITabBarController {
            
            if let viewController = tabController.viewControllers![0] as? CounterViewController {
                viewController.store = store
                _ = store.subscribe {
                    viewController.counterChanged()
                }
            }
            
            if let viewController = tabController.viewControllers![1] as? ToDoViewController {
                viewController.store = store
                _ = store.subscribe {
                    viewController.todosChanged()
                }
            }
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

