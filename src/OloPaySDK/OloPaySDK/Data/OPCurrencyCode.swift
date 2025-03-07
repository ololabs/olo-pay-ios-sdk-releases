// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPCurrencyCode.swift
//  OloPaySDK
//
//  Created by Richard Dowdy on 1/17/25.
//

import Foundation

/// An enum representing supported currency code
@objc public enum OPCurrencyCode : Int, CustomStringConvertible, CaseIterable {
    /// US Dollar
    case usd
    /// Canadian Dollar
    case cad
    
    /// A string representation of this enum
    public var description: String {
        switch self {
        case .usd:
            return "USD"
        case .cad:
            return "CAD"
        }
    }
}
