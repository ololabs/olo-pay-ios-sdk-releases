// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPCardField.swift
//  OloPaySDK
//
//  Created by Justin Anderson on 7/1/21.
//

import Foundation

/// Represents the different credit card fields
@objc public enum OPCardField: Int, CustomStringConvertible {
    /// The card's number field
    case number
    /// The card's expiration field
    case expiration
    /// The card's security code (CVV) field
    case cvv 
    /// The card's postal code field
    case postalCode
    /// An unknown card field
    case unknown
    
    /// A string representation of the card field
    public var description: String {
        switch self {
        case .number:
            return "number"
        case .expiration:
            return "expiration"
        case .cvv:
            return "cvv"
        case .postalCode:
            return "postalCode"
        case .unknown:
            return "unknown"
        }
    }
    
    /// Convenience method to convert a string to an OPCardField value
    public static func convert(from cardField: String) -> OPCardField {
        switch cardField.lowercased() {
        case OPCardField.number.description.lowercased():
            return .number
        case OPCardField.expiration.description.lowercased():
            return .expiration
        case OPCardField.cvv.description.lowercased():
            return .cvv
        case OPCardField.postalCode.description.lowercased():
            return .postalCode
        default:
            return .unknown
        }
    }
}
