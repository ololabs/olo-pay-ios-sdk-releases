// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  TestHarnessSettings.swift
//  OloPaySDKTestHarness
//
//  Created by Justin Anderson on 7/8/21.
//

import Foundation

protocol TestHarnessSettingsObserver: AnyObject {
    func settingsChanged(settings: TestHarnessSettingsProtocol)
}

protocol TestHarnessSettingsProtocol: NSObjectProtocol {
    // Settings not controlled by Plist Values
    var logCardInputChanges: Bool { get }
    var displayCardErrors: Bool { get }
    var customCardErrorMessages: Bool { get }
    var displayPostalCode: Bool { get }
    var useSingleLinePayment: Bool { get }
    var logFormValidChanges: Bool { get }
    var displayCvvErrors: Bool { get }
    var logCvvInputChanges: Bool { get }
    var customCvvErrorMessages: Bool { get }
    var displayLineItems: Bool { get }
    
    // API Settings
    var completeOloPayPayment: Bool { get }
    var baseAPIUrl: String? { get }
    var apiKey: String? { get }
    var restaurantId: UInt64? { get }
    var productId: UInt64? { get }
    var productQty: UInt? { get }
    var companyLabel: String? { get }
    var merchantId: String? { get }
    var productionEnvironment: Bool { get }
    var applePayBillingSchemeId: String? { get }
    
    /// User settings
    var useLoggedInUser: Bool { get }
    var userEmail: String? { get }
    var userPassword: String? { get }
    var savedCardBillingAccountId: String? { get }
    
}

// Class for managing settings for testing various SDK features
// NOTE: These settings are NOT persisted between launches of the app
class TestHarnessSettings: NSObject, TestHarnessSettingsProtocol {
    private var _observations = [ObjectIdentifier : Observation]()
    
    public var logCardInputChanges: Bool = false
    public var displayCardErrors: Bool = true
    public var customCardErrorMessages: Bool = false
    public var displayPostalCode: Bool = true
    public var useSingleLinePayment: Bool = true
    public var logFormValidChanges: Bool = false
    public var displayCvvErrors: Bool = true
    public var logCvvInputChanges: Bool = false
    public var customCvvErrorMessages: Bool = false
    public var displayLineItems: Bool = false
    
    public var completeOloPayPayment: Bool = ConfigUtils.getBoolPListValue(of: "Complete Olo Pay Payment") ?? false
    
    public var baseAPIUrl: String? = ConfigUtils.getStringPListValue(of: "Base API Url")?.replacingOccurrences(of: "\\", with: "")
    public var apiKey: String? = ConfigUtils.getStringPListValue(of: "API Key")
    public var restaurantId: UInt64? = ConfigUtils.getUInt64PListValue(of: "Restaurant Id")
    public var productId: UInt64? = ConfigUtils.getUInt64PListValue(of: "Product Id")
    public var productQty: UInt? = ConfigUtils.getUIntPListValue(of: "Product Qty")
    
    public var companyLabel: String? = ConfigUtils.getStringPListValue(of: "Company Label")
    public var merchantId: String? = ConfigUtils.getStringPListValue(of: "Merchant ID")
    public var productionEnvironment: Bool = ConfigUtils.getBoolPListValue(of: "Production Environment") ?? true

    public var applePayBillingSchemeId: String? = ConfigUtils.getStringPListValue(of: "Apple Pay Billing Scheme Id")
    
    public var useLoggedInUser: Bool = ConfigUtils.getBoolPListValue(of: "Use Logged In User") ?? false
    public var userEmail: String? = ConfigUtils.getStringPListValue(of: "User Email")
    public var userPassword: String? = ConfigUtils.getStringPListValue(of: "User Password")
    public var savedCardBillingAccountId: String? = ConfigUtils.getStringPListValue(of: "Saved Card Billing Account Id")
    
    public var allSettings: TestHarnessSettingsProtocol {
        get { return self }
    }
    
    private override init() {}
    
    public func addObserver(_ observer: TestHarnessSettingsObserver) {
        let id = ObjectIdentifier(observer)
        _observations[id] = Observation(observer: observer)
    }
    
    public func removeObserver(_ observer: TestHarnessSettingsObserver) {
        let id = ObjectIdentifier(observer)
        _observations.removeValue(forKey: id)
    }
    
    public func notifySettingsChanged() {
        for (id, observation) in _observations {
            guard let observer = observation.observer else {
                _observations.removeValue(forKey: id)
                continue
            }
            
            observer.settingsChanged(settings: self)
        }
    }
    
    static let sharedInstance = TestHarnessSettings()
}

private extension TestHarnessSettings {
    struct Observation {
        weak var observer: TestHarnessSettingsObserver?
    }
}
