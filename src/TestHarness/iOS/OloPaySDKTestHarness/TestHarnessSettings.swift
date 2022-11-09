// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  TestHarnessSettings.swift
//  OloPaySDKTestHarness
//
//  Created by Justin Anderson on 7/8/21.
//

import Foundation

// Class for managing settings for testing various SDK features
// NOTE: These settings are NOT persisted between launches of the app
class TestHarnessSettings {
    public var logCardInputChanges: Bool = false
    public var displayCardErrors: Bool = true
    public var customCardErrorMessages: Bool = false
    public var displayPostalCode: Bool = true
    public var useSingleLinePayment: Bool = true
    public var logFormValidChanges: Bool = false
    
    public var completeOloPayPayment: Bool? = ConfigUtils.getBoolPListValue(of: "Complete Olo Pay Payment")
    public var baseAPIUrl: String? = ConfigUtils.getStringPListValue(of: "Base API Url")?.replacingOccurrences(of: "\\", with: "")
    public var apiKey: String? = ConfigUtils.getStringPListValue(of: "API Key")
    public var restaurantId: UInt64? = ConfigUtils.getUInt64PListValue(of: "Restaurant Id")
    public var productId: UInt64? = ConfigUtils.getUInt64PListValue(of: "Product Id")
    public var productQty: UInt? = ConfigUtils.getUIntPListValue(of: "Product Qty")
    public var userEmail: String? = ConfigUtils.getStringPListValue(of: "User Email")
    public var companyLabel: String? = ConfigUtils.getStringPListValue(of: "Company Label")
    public var merchantId: String? = ConfigUtils.getStringPListValue(of: "Merchant ID")
    public var freshSetup: Bool = ConfigUtils.getBoolPListValue(of: "Fresh Setup") ?? false
    public var productionEnvironment: Bool = ConfigUtils.getBoolPListValue(of: "Production Environment") ?? true

    public var applePayBillingSchemeId: String? = ConfigUtils.getStringPListValue(of: "Apple Pay Billing Scheme Id")
    
    private init() {}
    
    static let sharedInstance = TestHarnessSettings()
}
