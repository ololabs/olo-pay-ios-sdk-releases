// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  CardErrorTypeTest.swift
//  OloPaySDKTests
//
//  Created by Kyle Szklenski on 12/8/21.
//

import XCTest
import Stripe
@testable import OloPaySDK

class CardErrorTypeTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testFrom_STPCardErrorType_to_CardErrorType() throws {
        let cases = [(STPCardErrorCode.cardDeclined, OPCardErrorType.cardDeclined), (STPCardErrorCode.expiredCard, OPCardErrorType.expiredCard),
                     (STPCardErrorCode.incorrectCVC, OPCardErrorType.invalidCvv), (STPCardErrorCode.incorrectZip, OPCardErrorType.invalidZip),
                     (STPCardErrorCode.incorrectNumber, OPCardErrorType.invalidNumber), (STPCardErrorCode.invalidCVC, OPCardErrorType.invalidCvv),
                     (STPCardErrorCode.invalidNumber, OPCardErrorType.invalidNumber), (STPCardErrorCode.invalidExpYear, OPCardErrorType.invalidExpYear),
                     (STPCardErrorCode.invalidExpMonth, OPCardErrorType.invalidExpMonth), (STPCardErrorCode.processingError, OPCardErrorType.processingError)]
        cases.forEach {
            XCTAssertEqual(OPCardErrorType.convert(from: $0), $1)
        }
    }
}
