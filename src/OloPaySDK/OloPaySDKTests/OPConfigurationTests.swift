// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPConfigurationTests.swift
//  OloPaySDKTests
//
//  Created by Richard Dowdy on 1/17/25.
//

import Foundation
import XCTest
@testable import OloPaySDK

class ConfigurationTests: XCTestCase {
    func testOPConfigurationConstructor_withoutCurrencyCodeOrCountryCode_returnsOPConfigurationWithDefaults() {
        let config = OPApplePayConfiguration(merchantId: "testMerchantId", companyLabel: "Foosburgers")
        XCTAssertEqual(config.merchantId, "testMerchantId")
        XCTAssertEqual(config.companyLabel, "Foosburgers")
        XCTAssertEqual(config.currencyCode.description, "USD")
        XCTAssertEqual(config.countryCode, "US")
        XCTAssertEqual(config.emailRequired, false)
        XCTAssertEqual(config.phoneNumberRequired, false)
        XCTAssertEqual(config.fullNameRequired, false)
        XCTAssertEqual(config.fullBillingAddressRequired, false)

    }
    
    func testOPConfigurationConstructor_withAllParametersSpecified_returnsCorrectOPConfigurationInstance() {
        let config = OPApplePayConfiguration(
            merchantId: "testMerchantId-2",
            companyLabel: "Foosburgers-2",
            currencyCode: OPCurrencyCode.cad,
            countryCode: "CA",
            emailRequired: true,
            phoneNumberRequired: true,
            fullNameRequired: true,
            fullBillingAddressRequired: true
        )
        XCTAssertEqual(config.merchantId, "testMerchantId-2")
        XCTAssertEqual(config.companyLabel, "Foosburgers-2")
        XCTAssertEqual(config.currencyCode.description, "CAD")
        XCTAssertEqual(config.countryCode, "CA")
        XCTAssertEqual(config.emailRequired, true)
        XCTAssertEqual(config.phoneNumberRequired, true)
        XCTAssertEqual(config.fullNameRequired, true)
        XCTAssertEqual(config.fullBillingAddressRequired, true)
    }
}
