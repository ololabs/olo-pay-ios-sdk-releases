// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPApplePayContextError.swift
//  OloPaySDK
//
//  Created by Justin Anderson on 7/1/21.
//

import Foundation
import Stripe

/// An enum representing ApplePay specific errors
@objc public enum OPApplePayContextError : Int, Error {
    /// The merchant id is missing
    case missingMerchantId
    /// The company label is missing
    case missingCompanyLabel
    /// The merchant id is empty
    case emptyMerchantId
    /// The company label is empty
    case emptyCompanyLabel
}
