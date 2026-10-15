// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPCardFieldStateProtocol.swift
//  OloPaySDK
//
//  Created by Justin Anderson on 8/21/23.
//

import Foundation

/// Protocol representing the state of a credit card field (card number, expiration, cvv, postal code).
@objc public protocol OPCardFieldStateProtocol : NSObjectProtocol {
    /// Whether or not the field is valid
    var isValid: Bool { get }
    
    /// Whether or not the field is empty
    var isEmpty: Bool { get }
    
    /// Whether or not the field has ever not been empty. Once `true`, it will not change back to `false`
    var wasEdited: Bool { get }
    
    /// Whether or not the field is currenlty the first responder
    var isFirstResponder: Bool { get }
    
    /// Whether or not the field has ever been the first responder. Once `true`, it will not change back to `false`
    /// - Note: This only gets set to `true` if the field lost first responder status while `wasEdited` was `true`.
    var wasFirstResponder: Bool { get }
}
