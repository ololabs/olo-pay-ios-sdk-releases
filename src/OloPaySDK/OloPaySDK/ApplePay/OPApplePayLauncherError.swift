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
}

