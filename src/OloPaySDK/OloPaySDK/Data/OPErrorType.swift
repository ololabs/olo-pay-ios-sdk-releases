// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPErrorType.swift
//  OloPaySDK
//
//  Created by Justin Anderson on 6/30/21.
//

import Foundation
import Stripe

internal let applePayContextErrorRawValue: Int = 1010
internal let generalErrorRawValue: Int = 1020

/// Possible error code values for OPErrors (NSErrors with the `OPError.oloPayDomain` domain
@objc public enum OPErrorType :  Int, CustomStringConvertible {
    /// Trouble connecting to servers
    case connectionError
    /// Request has invalid parameters
    case invalidRequestError
    /// General-purpose API error
    case apiError
    /// Something was wrong with the card details
    case cardError
    /// Operation was cancelled
    case cancellationError
    /// Something was wrong with the Apple Pay Context
    case applePayContextError
    /// An authentication error
    case authenticationError
    /// Other general errors
    case generalError
    
    internal static func convert(from key: STPErrorCode) -> OPErrorType {
        switch key {
        case .connectionError:
            return .connectionError
        case .invalidRequestError:
            return .invalidRequestError
        case .apiError:
            return .apiError
        case .cardError:
            return .cardError
        case .cancellationError:
            return .cancellationError
        case .ephemeralKeyDecodingError:
            return .generalError
        case .authenticationError:
            return .authenticationError
        @unknown default:
            return .generalError
        }
    }
    
    public var rawValue: Int {
        switch self {
        case .connectionError:
            return STPErrorCode.connectionError.rawValue
        case .invalidRequestError:
            return STPErrorCode.invalidRequestError.rawValue
        case .apiError:
            return STPErrorCode.apiError.rawValue
        case .cardError:
            return STPErrorCode.cardError.rawValue
        case .cancellationError:
            return STPErrorCode.cancellationError.rawValue
        case .applePayContextError:
            return applePayContextErrorRawValue
        case .authenticationError:
            return STPErrorCode.authenticationError.rawValue
        case .generalError:
            return generalErrorRawValue
        }
    }
    
    /// A string representation of this enum
    public var description: String {
        switch self {
        case .connectionError:
            return "connectionError"
        case .invalidRequestError:
            return "invalidRequestError"
        case .apiError:
            return "apiError"
        case .cardError:
            return "cardError"
        case .cancellationError:
            return "cancellationError"
        case .applePayContextError:
            return "applePayContextError"
        case .authenticationError:
            return "authenticationError"
        case .generalError:
            return "generalError"
        }
    }
}

