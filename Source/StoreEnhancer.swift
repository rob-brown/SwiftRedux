//
//  StoreEnhancer.swift
//  SwiftRedux
//
//  Created by Robert Brown on 11/11/15.
//  Copyright © 2015 Robert Brown. All rights reserved.
//

import Foundation

public struct StoreEnhancer<T,U> {
    public typealias StoreEnhancerFunction = StoreCreator<T>->StoreCreator<U>
    
    private let function: StoreEnhancerFunction
    
    public init(function: StoreEnhancerFunction) {
        self.function = function
    }
    
    public func enhance(creator: StoreCreator<T>) -> StoreCreator<U> {
        return self.function(creator)
    }
}
