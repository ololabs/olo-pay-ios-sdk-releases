// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  ErrorTypeTests.swift
//  OloPaySDKTests
//
//  Created by Kyle Szklenski on 12/14/21.
//

import XCTest
import Stripe
@testable import OloPaySDK

class ErrorTypeTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testConvertFrom_StripeErrorType_To_OloPayErrorType() throws {
        let cases = [(STPErrorCode.connectionError, OPErrorType.connectionError), (STPErrorCode.invalidRequestError, OPErrorType.invalidRequestError), (STPErrorCode.apiError, OPErrorType.apiError), (STPErrorCode.cardError, OPErrorType.cardError), (STPErrorCode.cancellationError, OPErrorType.cancellationError), (STPErrorCode.ephemeralKeyDecodingError, OPErrorType.generalError)]
        cases.forEach {
            XCTAssertEqual(OPErrorType.convert(from: $0), $1)
        }
    }
}
