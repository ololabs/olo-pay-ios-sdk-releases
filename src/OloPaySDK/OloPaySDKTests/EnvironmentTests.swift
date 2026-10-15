// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  EnvironmentTests.swift
//  OloPaySDK
//
//  Created by Richard Dowdy on 7/17/25.
//

import XCTest
@testable import OloPaySDK

class EnvironmentTests: XCTestCase {
    func testConvertFrom_String_to_OPEnvironment() throws {
        let cases = [
            ("test", OPEnvironment.test),
            ("TEST", OPEnvironment.test),
            ("production", OPEnvironment.production),
            ("PRODUCTION", OPEnvironment.production),
            ("randomString", OPEnvironment.production),
            ("", OPEnvironment.production)
        ]
        
        cases.forEach {
            XCTAssertEqual(OPEnvironment.convert(from: $0), $1)
        }
    }
}
