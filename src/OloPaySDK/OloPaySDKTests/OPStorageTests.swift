// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPStorageTests.swift
//  OloPaySDKTests
//
//  Created by Richard Dowdy on 3/30/23.
//

import XCTest
@testable import OloPaySDK

class OPStorageTests: XCTestCase {
    
    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }
    
    func testgetPublishablekey_withTestEnvironment_returnsTestKey() {
        OPStorage.testPublishableKey = "Test"
        
        XCTAssertEqual("Test", OPStorage.getPublishableKey(environment: OPEnvironment.test))
    }
    
    
    func testsetPublishableKey_withTestEnvironment_setsOnlyTestKey() {
        OPStorage.testPublishableKey = ""
        OPStorage.productionPublishableKey = ""

        OPStorage.setPublishableKey(environment: OPEnvironment.test, value: "Test")
        
        XCTAssertEqual("Test", OPStorage.testPublishableKey)
        XCTAssertTrue(OPStorage.productionPublishableKey.isEmpty)
    }
    
    func testgetPublishableKey_withProductionEnvironment_returnsProductionKey() {
        OPStorage.productionPublishableKey = "Production"
        
        XCTAssertEqual("Production", OPStorage.getPublishableKey(environment: OPEnvironment.production))
    }
    
    func testsetPublishableKey_withProductionEnvironment_setsOnlyProductionKey() {
        OPStorage.testPublishableKey = ""
        OPStorage.productionPublishableKey = ""

        OPStorage.setPublishableKey(environment: OPEnvironment.production, value: "Production")
        
        XCTAssertEqual("Production", OPStorage.productionPublishableKey)
        XCTAssertTrue(OPStorage.testPublishableKey.isEmpty)
    }
    
    func testReset_valuesReturnedToDefaults() {
        OPStorage.testPublishableKey = "Foo"
        OPStorage.productionPublishableKey = "Bar"
        OPStorage.environment = OPEnvironment.test.description
        
        OPStorage.reset()
        
        XCTAssertEqual("", OPStorage.getPublishableKey(environment: .test))
        XCTAssertEqual("", OPStorage.getPublishableKey(environment: .production))
        XCTAssertEqual("production", OPStorage.environment)
    }
}
