//
//  CounterViewController.swift
//  SwiftRedux
//
//  Created by Robert Brown on 10/28/15.
//  Copyright © 2015 Robert Brown. All rights reserved.
//

import UIKit

class CounterViewController: UIViewController {

    @IBOutlet weak var counterLabel: UILabel!
    var store: Store<AppState>?
    var notifier: Notifier?
    private var unsubscriber: Unsubscriber?
    
    deinit {
        unsubscriber?()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        unsubscriber = notifier?.subscribeToCounter(counterChanged)
    }
    
    func counterChanged(counter: Int) {
        counterLabel.text = String(counter)
    }
    
    @IBAction func tappedIncrement(sender: AnyObject) {
        let action = BasicAction(type: CounterAction.Increment.rawValue)
        _ = try? store?.dispatch(action)
    }
    
    @IBAction func tappedDecrement(sender: AnyObject) {
        let action = BasicAction(type: CounterAction.Decrement.rawValue)
        _ = try? store?.dispatch(action)
    }
}

