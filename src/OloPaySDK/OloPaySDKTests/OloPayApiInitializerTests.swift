// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OloPayApiInitializerTests.swift
//  OloPaySDKTests
//
//  Created by Justin Anderson on 11/30/21.
//

import XCTest
@testable import OloPaySDK

class OloPayApiInitializerTests: XCTestCase {
    let maxWaitSeconds: Double = 5

    override func setUpWithError() throws {
        OPStorage.reset()
    }

    override func tearDownWithError() throws {
    }

    func testSetup_environmentParameterNotSpecified_setupWithProductionEnvironment() {
        OloPayAPI.publishableKey = ""
        let expectation = XCTestExpectation(description: "setup() completed")
        
        OloPayApiInitializer().setup() {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: maxWaitSeconds)
        XCTAssertEqual(.production, OloPayAPI.environment)
    }
    
    func testSetup_productionEnvironmentSpecified_setupWithProductionEnvironment() {
        OloPayAPI.publishableKey = ""
        let expectation = XCTestExpectation(description: "setup() completed")
        
        OloPayApiInitializer().setup(for: .production) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: maxWaitSeconds)
        XCTAssertEqual(.production, OloPayAPI.environment)
    }
    
    func testSetup_testEnvironmentSpecified_setupWithTestEnvironment() {
        OloPayAPI.publishableKey = ""
        let expectation = XCTestExpectation(description: "setup() completed")
        
        OloPayApiInitializer().setup(for: .test) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: maxWaitSeconds)
        XCTAssertEqual(.test, OloPayAPI.environment)
    }
    
    func testSetup_publishableKeyEmpty_publishableKeyUpdated() {
        OloPayAPI.publishableKey = ""
        let expectation = XCTestExpectation(description: "setup() completed")
        
        OloPayApiInitializer().setup() {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: maxWaitSeconds)
        XCTAssertNotEqual("", OloPayAPI.publishableKey)
    }
    
    func testSetup_withCachedPublishableKey_publishableKeyNotChanged() {
        OloPayAPI.publishableKey = "foobar"
        
        let expectation = XCTestExpectation(description: "setup() completed")
        
        OloPayApiInitializer().setup() {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: maxWaitSeconds)
        XCTAssertEqual("foobar", OloPayAPI.publishableKey)
    }
    
    
}
