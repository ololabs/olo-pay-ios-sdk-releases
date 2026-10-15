// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPApplePayConfiguration.swift
//  OloPaySDK
//
//  Created by Richard Dowdy on 1/17/25.
//

import Foundation
import PassKit

/// Configuration paramaters required for setting up ApplePay
@objc public class OPApplePayConfiguration : NSObject {
    static let validCountryCodeLength = 2
    
    /// The merchant ID registered with Apple
    public let merchantId: String
    
    /// The company label that will be displayed on the ApplePay payment sheet
    public let companyLabel: String
    
    /// The currency code to use for Apple Pay transactions
    /// Default value is `OPCurrencyCode.usd`
    public let currencyCode: OPCurrencyCode
    
    /// A two-character country code for the vendor that will be processing transactions
    /// Default value is `US`
    public let countryCode: String
    
    /// Whether Apple Pay collects and returns a full billing address when processing transactions
    /// If `false`, only postal code and country code will be provided. Default value is `false`
    public let fullBillingAddressRequired: Bool
    
    /// Whether Apple Pay collects and returns a phone number when processing transactions
    /// Default value is `false`
    public let phoneNumberRequired: Bool
    
    /// Whether Apple Pay collects and returns a name when processing transactions
    /// Default value is `false`
    public let fullNameRequired: Bool
    
    /// Whether Apple Pay collects and returns an email address when processing transactions
    /// Default value is `false`
    public let emailRequired: Bool
    
    /// Whether Apple Pay collects and returns a phonetic name when processing transactions
    /// Default value is `false`
    public let fullPhoneticNameRequired: Bool

    @objc public init(
        merchantId: String,
        companyLabel: String,
        currencyCode: OPCurrencyCode = .usd,
        countryCode: String = "US",
        emailRequired: Bool = false,
        phoneNumberRequired: Bool = false,
        fullNameRequired: Bool = false,
        fullBillingAddressRequired: Bool = false,
        fullPhoneticNameRequired: Bool = false
    ) {
        self.merchantId = merchantId
        self.companyLabel = companyLabel
        self.currencyCode = currencyCode
        self.countryCode = countryCode
        self.emailRequired = emailRequired
        self.phoneNumberRequired = phoneNumberRequired
        self.fullNameRequired = fullNameRequired
        self.fullBillingAddressRequired = fullBillingAddressRequired
        self.fullPhoneticNameRequired = fullPhoneticNameRequired
    }
}

