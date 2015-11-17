//
//  GCDExtension.swift
//  SwiftRedux
//
//  Created by Robert Brown on 11/14/15.
//  Copyright © 2015 Robert Brown. All rights reserved.
//

import Foundation

public func dispatch_main_queue(closure: ()->()) {
    if NSThread.isMainThread() {
        closure()
    }
    else {
        dispatch_async(dispatch_get_main_queue(), closure)
    }
}
