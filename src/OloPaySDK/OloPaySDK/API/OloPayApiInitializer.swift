// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OloPayApiInitializerProtocol.swift
//  OloPaySDK
//
//  Created by Justin Anderson on 10/13/21.
//

import Foundation
import Stripe

/// Protocol for mocking/testing purposes. See `OloPayApiInitializer` for documentation
@objc public protocol OloPayApiInitializerProtocol : NSObjectProtocol {
    /// Set up the Olo Pay API. See `OloPayApiInitializer.setup(...)` for method documentation
    @objc func setup(with parameters: OPSetupParameters?, completion: OPVoidBlock?)
}

/// Class to set up and initialize the Olo Pay API
@objc public class OloPayApiInitializer : NSObject, OloPayApiInitializerProtocol {
    /// Setup the Olo Pay API
    /// - Important: This should be called as early as possible in the app, preferably in the AppDelegate or SceneDelegate.
    /// - Parameters
    ///     - parameters:   Optional parameters to customize the Olo Pay API
    ///     - completion:            Optional completion handler for when the SDK is fully initialized
    @objc public func setup(with parameters: OPSetupParameters? = nil, completion: OPVoidBlock? = nil) {
        var forceKeyUpdate = false
        OloPayAPI.environment = OPEnvironment.production
        
        if let setupParams = parameters {
            OloPayAPI.environment = setupParams.environment
            forceKeyUpdate = setupParams.freshSetup
            OPApplePayContext.merchantId = setupParams.applePayMerchantId
            OPApplePayContext.companyLabel = setupParams.applePayCompanyLabel
        }
        
        if forceKeyUpdate || OloPayAPI.publishableKey == "" {
            OloPayAPI.updatePublishableKey {
                if let completion = completion { completion() }
            }
        }
        else {
            StripeAPI.defaultPublishableKey = OloPayAPI.publishableKey
            if let completion = completion { completion() }
        }
    }
}
