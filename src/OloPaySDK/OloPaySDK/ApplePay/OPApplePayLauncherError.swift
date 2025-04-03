// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPApplePayLauncherError.swift
//  OloPaySDK
//
//  Created by Justin Anderson on 7/1/21.
//

import Foundation
import Stripe

/// An enum representing ApplePay specific errors
@objc public enum OPApplePayLauncherError : Int, Error {
    /// The configuration has not been set
    case configurationNotSet
    /// The delegate has not been set
    case delegateNotSet
    /// The merchant id is empty
    case emptyMerchantId
    /// The company label is empty
    case emptyCompanyLabel
    /// The country code is invalid
    case invalidCountryCode
    /// The device is not set up for Apple Pay payments
    case applePayNotSupported
    /// The line items sum total does not equal the total price 
    case lineItemTotalMismatchError
    /// This could occur for various reasons which include:
    ///     * A payment sheet has aleady been launched and not yet been dismissed
    ///     * A merchant id that has not been associated with a payment processing certificate or is not fully configured
    ///     * An invalid country code
    ///     * Regional restrictions on Apple Pay
    ///     * Parental controls or software restrictions on Apple Pay
    case unexpectedError
}

