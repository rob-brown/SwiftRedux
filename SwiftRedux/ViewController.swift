//
//  ViewController.swift
//  SwiftRedux
//
//  Created by Robert Brown on 10/28/15.
//  Copyright © 2015 Robert Brown. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var counterLabel: UILabel!
    var store: Store?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        counterChanged()
    }
    
    func counterChanged() {
        guard let count = store?.currentState() as? Int else { return }
        counterLabel.text = String(count)
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

