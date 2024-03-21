// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  CardBrandTypeTests.swift
//  OloPaySDKTests
//
//  Created by Kyle Szklenski on 12/14/21.
//

import XCTest
@testable import OloPaySDK
import Stripe

class CardBrandTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testConvertFrom_StripeBrand_To_OloPayBrand() throws {
        let cases = [(STPCardBrand.visa, OPCardBrand.visa, true), (STPCardBrand.mastercard, OPCardBrand.mastercard, true), (STPCardBrand.amex, OPCardBrand.amex, true),
                     (STPCardBrand.discover, OPCardBrand.discover, true), (STPCardBrand.unknown, OPCardBrand.unknown, true), (STPCardBrand.JCB, OPCardBrand.unsupported, true),
                     (STPCardBrand.dinersClub, OPCardBrand.unsupported, true), (STPCardBrand.unionPay, OPCardBrand.unsupported, true), (STPCardBrand.visa, OPCardBrand.unknown, false),
                     (STPCardBrand.mastercard, OPCardBrand.visa, false), (STPCardBrand.unknown, OPCardBrand.discover, false)]
        cases.forEach {
            XCTAssertEqual(OPCardBrand.convert(from: $0) == $1, $2)
        }
    }
    
    func testConvertFrom_OloPayBrand_To_StripeBrand() throws {
        let cases = [(STPCardBrand.visa, OPCardBrand.visa, true), (STPCardBrand.mastercard, OPCardBrand.mastercard, true), (STPCardBrand.amex, OPCardBrand.amex, true),
                     (STPCardBrand.discover, OPCardBrand.discover, true), (STPCardBrand.unknown, OPCardBrand.unknown, true)]
        cases.forEach {
            XCTAssertEqual(OPCardBrand.convert(from: $1) == $0, $2)
        }
    }
    
    func testConvertFrom_OloPayCardBrand_To_String() throws {
        let cases = [(OPCardBrand.amex, "Amex"), (OPCardBrand.discover, "Discover"), (OPCardBrand.mastercard, "Mastercard"), (OPCardBrand.visa, "Visa"), (OPCardBrand.unknown, "Unknown")]
        cases.forEach {
            XCTAssertEqual($0.description, $1)
        }
    }
}
