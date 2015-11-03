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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        counterChanged()
    }
    
    func counterChanged() {
        if let count = store?.currentState().counter {
            counterLabel.text = String(count)
        }
        else {
            counterLabel.text = "N/A"
        }
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

