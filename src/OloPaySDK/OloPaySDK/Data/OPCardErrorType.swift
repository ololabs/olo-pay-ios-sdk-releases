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
    /// The card number is not a valid credit card number.
    case invalidNumber
    /// The card has an invalid expiration month.
    case invalidExpMonth
    /// The card has an invalid expiration year.
    case invalidExpYear
    /// The card has an invalid CVC.
    case invalidCVC
    /// The card number is incorrect.
    case incorrectNumber
    /// The card is expired.
    case expiredCard
    /// The card was declined.
    case cardDeclined
    /// The card has an incorrect CVC.
    case incorrectCVC
    /// An error occured while processing this card.
    case processingError
    /// The postal code is incorrect.
    case incorrectZip
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
        case .invalidCVC:
            return "invalidCVC"
        case .incorrectNumber:
            return "incorrectNumber"
        case .expiredCard:
            return "expiredCard"
        case .cardDeclined:
            return "cardDeclined"
        case .incorrectCVC:
            return "incorrectCVC"
        case .processingError:
            return "processingError"
        case .incorrectZip:
            return "incorrectZip"
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
            return .invalidCVC
        case .incorrectNumber:
            return .incorrectNumber
        case .expiredCard:
            return .expiredCard
        case .cardDeclined:
            return .cardDeclined
        case .incorrectCVC:
            return .incorrectCVC
        case .processingError:
            return .processingError
        case .incorrectZip:
            return .incorrectZip
        @unknown default:
            return .unknownCardError
        }
    }
}
