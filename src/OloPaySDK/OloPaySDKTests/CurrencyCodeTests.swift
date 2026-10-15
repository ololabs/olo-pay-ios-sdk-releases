// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  CurrencyCodeTests.swift
//  OloPaySDK
//
//  Created by Richard Dowdy on 7/17/25.
//

import XCTest
@testable import OloPaySDK

class CurrencyCodeTests: XCTestCase {
    func testConvertFrom_String_to_OPCurrencyCode() throws {
        let cases = [
            ("USD", OPCurrencyCode.usd),
            ("usd", OPCurrencyCode.usd),
            ("CAD", OPCurrencyCode.cad),
            ("cad", OPCurrencyCode.cad),
            ("eur", nil),
            ("", nil),
            ("randomString", nil),
        ]
        
        cases.forEach {
            XCTAssertEqual(OPCurrencyCode.convert(from: $0), $1)
        }
    }
}
