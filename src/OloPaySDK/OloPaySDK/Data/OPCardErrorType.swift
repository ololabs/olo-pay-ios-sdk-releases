// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPCardErrorType.swift
//  OloPaySDK
//
//  Created by Justin Anderson on 6/30/21.
//

import Foundation
import Stripe

/// Possible card error codes when there was an error tokenizing a card. These values can be
/// accessed from the `OPError.cardErrorType` property.
@objc public enum OPCardErrorType : Int, CustomStringConvertible {
    /// The card number is invalid (empty, incorrect format, incomplete, etc)
    case invalidNumber
    /// The expiration month is invalid.
    case invalidExpMonth
    /// The expiration year is invalid
    case invalidExpYear
    /// The card is expired.
    case expiredCard
    /// The card was declined.
    case cardDeclined
    /// An error occured while processing this card.
    case processingError
    /// The postal code is invalid (empty, incorrect format, incomplete, etc).
    case invalidZip
    /// The CVV is not valid (empty, incorrect format, incomplete, etc)
    case invalidCvv
    /// An unknown or unaccounted-for error occured
    case unknownCardError
    
    /// A string representation of this enum
    public var description: String {
        switch self {
        case .invalidNumber:
            return "invalidNumber"
        case .invalidExpMonth:
            return "invalidExpMonth"
        case .invalidExpYear:
            return "invalidExpYear"
        case .expiredCard:
            return "expiredCard"
        case .cardDeclined:
            return "cardDeclined"
        case .processingError:
            return "processingError"
        case .invalidZip:
            return "invalidZip"
        case .invalidCvv:
            return "invalidCvv"
        case .unknownCardError:
            return "unknownCardError"
        }
    }
    
    internal static func convert(from key: STPCardErrorCode) -> OPCardErrorType {
        switch key {
        case .invalidNumber:
            return .invalidNumber
        case .invalidExpMonth:
            return .invalidExpMonth
        case .invalidExpYear:
            return .invalidExpYear
        case .invalidCVC:
            return .invalidCvv
        case .incorrectNumber:
            return .invalidNumber
        case .expiredCard:
            return .expiredCard
        case .cardDeclined:
            return .cardDeclined
        case .incorrectCVC:
            return .invalidCvv
        case .processingError:
            return .processingError
        case .incorrectZip:
            return .invalidZip
        @unknown default:
            return .unknownCardError
        }
    }
}
