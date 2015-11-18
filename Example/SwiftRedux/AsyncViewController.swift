//
//  AsyncViewController.swift
//  SwiftRedux
//
//  Created by Robert Brown on 11/14/15.
//  Copyright © 2015 Robert Brown. All rights reserved.
//

import UIKit

class AsyncViewController: UIViewController, ReduxTarget {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
    @IBOutlet weak var randomNumberLabel: UILabel?
    
    var store: Store<History<AppState>>?
    var notifier: Notifier?
    private var unsubscribers = [Unsubscriber]()
    
    deinit {
        unsubscribers.forEach { $0() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let notifier = notifier else { return }
        let unsubscriber1 = notifier.randomNumberNotifier.subscribe(numberChanged)
        let unsubscriber2 = notifier.randomNumberLoadingNotifier.subscribe(loadingChanged)
        unsubscribers = [unsubscriber1, unsubscriber2]
    }
    
    func numberChanged(number: Int) {
        dispatch_main_queue {
            self.randomNumberLabel?.text = String(number)
        }
    }
    
    func loadingChanged(loading: Bool) {
        dispatch_main_queue {
            if loading {
                self.activityIndicator?.startAnimating()
            }
            else {
                self.activityIndicator?.stopAnimating()
            }
        }
    }
    
    @IBAction func tappedGenerate(sender: UIButton) {
        let action = AsyncAction<History<AppState>>(type: RandomAction.RandomNumber.rawValue) { dispatcher, stateFetcher in
            let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            dispatch_async(queue) {
                let startAction = RandomActionCreater.randomNumberLoading(true)
                _ = try? dispatcher(startAction)
                
                let delay = dispatch_time(DISPATCH_TIME_NOW, 3 * Int64(NSEC_PER_SEC))
                dispatch_after(delay, queue) {
                    let number = Int(arc4random_uniform(100))
                    let resultAction = RandomActionCreater.randomNumber(number)
                    _ = try? dispatcher(resultAction)
                    let endAction = RandomActionCreater.randomNumberLoading(false)
                    _ = try? dispatcher(endAction)
                }
            }
        }
        _ = try? store?.dispatch(action)
    }
}
