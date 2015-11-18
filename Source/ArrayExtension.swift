//
//  ArrayExtension.swift
//  SwiftRedux
//
//  Created by Robert Brown on 11/10/15.
//  Copyright © 2015 Robert Brown. All rights reserved.
//

import Foundation

extension Array {
    
    public func take(n: Int) -> Array<Element> {
        let count = self.count
        
        if count == 0 {
            return []
        }
        
        let end = min(max(0, Int(n)), count)
        
        return Array(self[0..<end])
    }
    
    public func drop(n: Int) -> Array<Element> {
        let count = self.count
        
        if count == 0 {
            return self
        }
        
        let end = count
        let start = max(0, min(Int(n), count))
        
        return Array(self[start..<end])
    }
}
