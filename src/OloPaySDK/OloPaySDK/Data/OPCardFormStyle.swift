// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPCardFormStyle.swift
//  OloPaySDK
//
//  Created by Justin Anderson on 7/22/21.
//

import Foundation
import Stripe

/// Options for configuring the display of `OPPaymentCardDetailsForm` instances
@objc public enum OPCardFormStyle : Int, CustomStringConvertible {
    /// Displays the form in a rounded rect with full separators between each input field.
    case standard
    /// Displays the form without an outer border and underlines under each input field.
    case borderless
    
    /// A string representation of this enum
    public var description: String {
        switch self {
        case .standard:
            return "standard"
        case .borderless:
            return "borderless"
        }
    }
    
    /// Convenience method to convert a string to an OPCardFormStyle value
    public static func convert(from cardFormStyle: String) -> OPCardFormStyle {
        switch cardFormStyle.lowercased() {
        case OPCardFormStyle.borderless.description:
            return .borderless
        default:
            return .standard
        }
    }
    
    internal static func convert(from type: STPCardFormViewStyle) -> OPCardFormStyle {
        switch type {
        case .standard:
            return .standard
        case .borderless:
            return .borderless
        @unknown default:
            return .standard
        }
    }
    
    internal static func convert(from type: OPCardFormStyle) -> STPCardFormViewStyle {
        switch type {
        case .standard:
            return .standard
        case .borderless:
            return .borderless
        }
    }
}
