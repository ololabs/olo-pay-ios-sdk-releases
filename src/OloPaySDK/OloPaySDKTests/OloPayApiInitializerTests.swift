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
    }

    override func tearDownWithError() throws {
    }

    func testSetup_withFreshSetup_publishableKeyWithValue_publishableKeyUpdated() {
        OloPayAPI.publishableKey = "foobar"
        let params = OPSetupParameters(withFreshSetup: true)
        let expectation = XCTestExpectation(description: "setup() completed")
        
        OloPayApiInitializer().setup(with: params) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: maxWaitSeconds)
        XCTAssertNotEqual("foobar", OloPayAPI.publishableKey)
    }
    
    func testSetup_withFreshSetup_publishableKeyEmpty_publishableKeyUpdated() {
        OloPayAPI.publishableKey = ""
        let params = OPSetupParameters(withFreshSetup: true)
        let expectation = XCTestExpectation(description: "setup() completed")
        
        OloPayApiInitializer().setup(with: params) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: maxWaitSeconds)
        XCTAssertNotEqual("", OloPayAPI.publishableKey)
    }
    
    func testSetup_withoutFreshSetup_withCachedPublishableKey_publishableKeyNotChanged() {
        OloPayAPI.publishableKey = "foobar"
        let params = OPSetupParameters(withFreshSetup: false)
        let expectation = XCTestExpectation(description: "setup() completed")
        
        OloPayApiInitializer().setup(with: params) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: maxWaitSeconds)
        XCTAssertEqual("foobar", OloPayAPI.publishableKey)
    }
    
    func testSetup_withoutFreshSetup_publishableKeyEmpty_publishableKeyUpdated() {
        OloPayAPI.publishableKey = ""
        let params = OPSetupParameters(withFreshSetup: false)
        let expectation = XCTestExpectation(description: "setup() completed")
        
        OloPayApiInitializer().setup(with: params) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: maxWaitSeconds)
        XCTAssertNotEqual("", OloPayAPI.publishableKey)
    }
}
