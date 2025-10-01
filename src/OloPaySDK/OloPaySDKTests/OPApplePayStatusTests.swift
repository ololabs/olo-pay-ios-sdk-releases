// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  PaymentStatusTypeTests.swift
//  OloPaySDKTests
//
//  Created by Kyle Szklenski on 12/14/21.
//

import XCTest
@testable import OloPaySDK
import Stripe

class OPApplePayStatusTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    let statusCases = [
        (STPPaymentStatus.error, OPApplePayStatus.error),
        (STPPaymentStatus.success, OPApplePayStatus.success),
        (STPPaymentStatus.userCancellation, OPApplePayStatus.userCancellation),
    ]
    
    func testConvertFrom_stripePaymentStatus_to_oloPayApplePayStatus() throws {
        statusCases.forEach {
            XCTAssertEqual(OPApplePayStatus.convert(from: $0), $1)
        }
    }
    
    func testConvertFrom_oloPayApplePayStatus_to_stripePaymentStatus() throws {
        statusCases.forEach {
            XCTAssertEqual(OPApplePayStatus.convert(from: $1), $0)
        }
    }
    
    func testConvertFrom_oloPayApplePayTimeoutStatus_to_stripeUserCancellationPaymentStatus() throws {
        // NOTE: This is a one-way test because Stripe doesn't have the concept of user cancellation with Apple Pay
        XCTAssertEqual(OPApplePayStatus.convert(from: .timeout), .userCancellation)
    }
}
