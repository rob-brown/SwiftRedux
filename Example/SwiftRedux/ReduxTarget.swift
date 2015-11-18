//
//  ReduxTarget.swift
//  SwiftRedux
//
//  Created by Robert Brown on 11/17/15.
//  Copyright © 2015 Robert Brown. All rights reserved.
//

import Foundation

protocol ReduxTarget {
    var store: Store<History<AppState>>? { get set }
    var notifier: Notifier? { get set }
}
