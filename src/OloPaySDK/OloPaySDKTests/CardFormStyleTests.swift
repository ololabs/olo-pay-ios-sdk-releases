// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  CardFormStyleTests.swift
//  OloPaySDKTests
//
//  Created by Kyle Szklenski on 12/14/21.
//

import XCTest
import Stripe
@testable import OloPaySDK

class CardFormStyleTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testConvertFrom_StripeCardFormViewStyle_To_OloPayCardFormStyle() throws {
        let cases = [(STPCardFormViewStyle.borderless, OPCardFormStyle.borderless), (STPCardFormViewStyle.standard, OPCardFormStyle.standard)]
        cases.forEach {
            XCTAssertEqual(OPCardFormStyle.convert(from: $0), $1)
        }
    }
    
    func testConvertFrom_OloPayCardFormStyle_To_StripeCardFormViewStyle() throws {
        let cases = [(STPCardFormViewStyle.borderless, OPCardFormStyle.borderless), (STPCardFormViewStyle.standard, OPCardFormStyle.standard)]
        cases.forEach {
            XCTAssertEqual(OPCardFormStyle.convert(from: $1), $0)
        }
    }

}
