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

class PaymentStatusTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    
    func testConvertFrom_StripePaymentStatus_To_OloPayPaymentStatus() throws {
        let cases = [(STPPaymentStatus.error, OPPaymentStatus.error), (STPPaymentStatus.success, OPPaymentStatus.success), (STPPaymentStatus.userCancellation, OPPaymentStatus.userCancellation)]
        cases.forEach {
            XCTAssertEqual(OPPaymentStatus.convert(from: $0), $1)
        }
    }
    
    func testConvertFrom_OloPayPaymentStatus_To_StripePaymentStatus() throws {
        let cases = [(STPPaymentStatus.error, OPPaymentStatus.error), (STPPaymentStatus.success, OPPaymentStatus.success), (STPPaymentStatus.userCancellation, OPPaymentStatus.userCancellation)]
        cases.forEach {
            XCTAssertEqual(OPPaymentStatus.convert(from: $1), $0)
        }
    }

}
