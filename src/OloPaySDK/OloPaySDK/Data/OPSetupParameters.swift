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
    /// If true, this will be treated as a fresh setup of the API and cached values will be overwritten.
    /// This is especially useful for testing purposes when switching between Dev and Production environments
    /// - Note: This should generall be set to false for production builds
    public let freshSetup: Bool
    
    /// If using ApplePay, this is the merchant Id registered with Apple
    /// - Important: This is required when using ApplePay
    public let applePayMerchantId: String?
    
    /// If using ApplePay, this is the company label that will be displayed on the ApplePay payment sheet
    /// - Important: This is required when using ApplePay
    public let applePayCompanyLabel: String?
    
    public let environment: OPEnvironment
    
    /// Creates an instance of `OPSetupParameters` to be used with `OloPayApiInitializer.setup(...)`
    /// - Parameters:
    ///     - environment: The environment the SDK will run in. Defaults to `OPEnvironment.production`
    ///     - freshSetup: Ignore any cached setup values and treat this as a fresh setup. Should typically be `false` for release builds. Defaults to `false`
    ///     - merchantId: ApplePay merchant Id registered with Apple
    ///     - companyLabel: Company name displayed on the ApplePay sheet
    public init(withEnvironment environment: OPEnvironment? = OPEnvironment.production, withFreshSetup freshSetup: Bool? = false, withApplePayMerchantId merchantId : String? = "", withApplePayCompanyLabel companyLabel : String? = "") {
        self.environment = environment!
        self.freshSetup = freshSetup!
        applePayMerchantId = merchantId
        applePayCompanyLabel = companyLabel
    }
}
