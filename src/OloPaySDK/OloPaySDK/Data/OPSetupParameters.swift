// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPSetupParameters.swift
//  OloPaySDK
//
//  Created by Justin Anderson on 6/17/21.
//

import Foundation

/// Optional parameters for setting up the Olo Pay API
@objc public class OPSetupParameters : NSObject {
    /// This property is deprecated and will be removed in a future release
    @available(*, deprecated, message: "The freshSetup parameter is deprecated and will be removed in a future release")
    public let freshSetup: Bool
    
    /// If using ApplePay, this is the merchant Id registered with Apple
    /// - Important: This is required when using ApplePay
    public let applePayMerchantId: String?
    
    /// If using ApplePay, this is the company label that will be displayed on the ApplePay payment sheet
    /// - Important: This is required when using ApplePay
    public let applePayCompanyLabel: String?
    
    /// The environment the SDK is going to be used in
    public let environment: OPEnvironment
        
    /// This constructor is deprecated. Alternative constructors that don't take a `freshSetup` parameter should be used instead.
    @available(*, deprecated, message: "Use alternative constructors without the freshSetup parameter")
    public init(
        withEnvironment environment: OPEnvironment? = OPEnvironment.production,
        withFreshSetup freshSetup: Bool? = false,
        withApplePayMerchantId merchantId : String? = "",
        withApplePayCompanyLabel companyLabel : String? = ""
    ) {
        self.environment = environment!
        self.freshSetup = freshSetup ?? false
        applePayMerchantId = merchantId
        applePayCompanyLabel = companyLabel
    }
    
    public init(
        withEnvironment environment: OPEnvironment? = OPEnvironment.production,
        withApplePayMerchantId merchantId : String? = "",
        withApplePayCompanyLabel companyLabel : String? = ""
    ) {
        self.environment = environment!
        self.freshSetup = false
        applePayMerchantId = merchantId
        applePayCompanyLabel = companyLabel
    }
}
