// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPCardBrand.swift
//  OloPaySDK
//
//  Created by Justin Anderson on 5/29/21.
//

import Foundation
import Stripe

/// An enum representing card brands supported by Olo Pay
/// - Important: See the `OPCardBrand.description` property for how to use this enum when submitting a basket to the Olo Ordering API
@objc public enum OPCardBrand : Int, CustomStringConvertible {
    /// Visa
    case visa
    /// American Express
    case amex
    /// MasterCard
    case mastercard
    /// Discover
    case discover
    /// Unsupported card type
    case unsupported
    /// Unknown card type
    case unknown

    /// A string representation of this enum. Use this as the `cardtype` when submitting a basket to the Olo Ordering API
    /// - Important: If the value is `unknown` the basket submission will fail
    public var description: String {
        switch self {
        case .visa:
            return "Visa"
        case .amex:
            return "Amex"
        case .mastercard:
            return "Mastercard"
        case .discover:
            return "Discover"
        case .unsupported:
            return "Unsupported"
        case .unknown:
            return "Unknown"
        }
    }
    
    /// Convenience method to convert a string to an OPCardBrand value
    public static func convert(from cardBrand: String) -> OPCardBrand {
        switch cardBrand.lowercased() {
        case OPCardBrand.visa.description.lowercased():
            return .visa
        case OPCardBrand.amex.description.lowercased():
            return .amex
        case OPCardBrand.mastercard.description.lowercased():
            return .mastercard
        case OPCardBrand.discover.description.lowercased():
            return .discover
        case OPCardBrand.unsupported.description.lowercased():
            return .unsupported
        default:
            return .unknown
        }
    }

    static func convert(from cardBrand: STPCardBrand?) -> OPCardBrand {
        switch cardBrand {
        case .visa:
            return OPCardBrand.visa
        case .amex:
            return OPCardBrand.amex
        case .mastercard:
            return OPCardBrand.mastercard
        case .discover,
             .JCB,
             .dinersClub,
             .unionPay:
            return OPCardBrand.discover
        case .cartesBancaires:
            return OPCardBrand.unsupported
        case .unknown,
             .none:
             fallthrough
        @unknown default:
            return OPCardBrand.unknown
        }
    }

    static func convert(from cardBrand: OPCardBrand?) -> STPCardBrand {
        switch cardBrand {
        case .visa:
            return STPCardBrand.visa
        case .amex:
            return STPCardBrand.amex
        case .mastercard:
            return STPCardBrand.mastercard
        case .discover:
            return STPCardBrand.discover
        case .unknown,
             .unsupported,
             .none:
             fallthrough
        @unknown default:
            return STPCardBrand.unknown
        }
    }
}
