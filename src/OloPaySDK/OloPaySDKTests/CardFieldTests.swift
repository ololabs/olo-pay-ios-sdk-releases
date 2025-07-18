// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  CardFieldTests.swift
//  OloPaySDKTests
//
//  Created by Kyle Szklenski on 12/14/21.
//
import XCTest
import Stripe
@testable import OloPaySDK

class CardFieldTests : XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testConvertFrom_OloPayCardField_To_String() throws {
        let cases = [(OPCardField.number, "number"), (OPCardField.expiration, "expiration"), (OPCardField.cvv, "cvv"), (OPCardField.postalCode, "postalCode"), (OPCardField.unknown, "unknown")]
        cases.forEach {
            XCTAssertEqual($0.description, $1)
        }
    }

    func testConvertFrom_String_to_OloPayCardField() throws {
        let cases = [
            ("number", OPCardField.number), ("expiration", OPCardField.expiration), ("cvv", OPCardField.cvv),
            ("postalCode", OPCardField.postalCode), ("unknown", OPCardField.unknown), ("Number", OPCardField.number),
            ("Expiration", OPCardField.expiration), ("Cvv", OPCardField.cvv), ("PostalCode", OPCardField.postalCode),
            ("Unknown", OPCardField.unknown), ("randomString", OPCardField.unknown), ("", OPCardField.unknown)
        ]
        cases.forEach {
            XCTAssertEqual(OPCardField.convert(from: $0) == $1, true)
        }
    }
}
