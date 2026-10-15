// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPCardFieldState.swift
//  OloPaySDK
//
//  Created by Justin Anderson on 8/21/23.
//

import Foundation

class OPCardFieldState: NSObject, OPCardFieldStateProtocol {
    var isValid = false
    var isEmpty = true
    var wasEdited = false
    var isFirstResponder = false
    var wasFirstResponder = false
    
    @objc required override init() {
        super.init()
    }
    
    internal func reset() {
        isValid = false
        isEmpty = true
        wasEdited = false
        isFirstResponder = false
        wasFirstResponder = false
    }
    
    @objc public override var description: String {
        let properties = [
            String(format: "%@: %p", NSStringFromClass(OPCardFieldState.self), self),
            "isValid = \(String(describing: isValid))",
            "isEmpty = \(String(describing: isEmpty))",
            "wasEdited = \(String(describing: wasEdited))",
            "isFirstResponder = \(String(describing: isFirstResponder))",
            "wasFirstResponder = \(String(describing: wasFirstResponder))"
        ]
        
        return "<\(properties.joined(separator: "; "))>"
    }
}
