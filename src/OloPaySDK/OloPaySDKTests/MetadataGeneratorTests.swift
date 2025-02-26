// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  MetadataGeneratorTests.swift
//  OloPaySDKTests
//
//  Created by Richard Dowdy on 5/30/23.
//

import XCTest
@testable import OloPaySDK

final class MetadataGeneratorTests: XCTestCase {

    let _applePayCompanyLabel = "Test Company"
    let _applePayMerchantId = "com.merchant.test"
    
    override func setUpWithError() throws {
        OloPayAPI.sdkWrapperInfo = nil
    }
    
    func testMetadataGenerator_withNativeSingleLineInputSource_containsCreationSourceData() {
        let metadata = getMetadata(.singleLineInput)

        XCTAssertEqual("singleLineInput", metadata["CreationSource"])
        assertNoHybridData(metadata)
        assertNoApplePayData(metadata)
    }
    
    func testMetadataGenerator_withNativeFormLineInputSource_containsCreationSourceData() {
        let metadata = getMetadata(.formInput)
        
        XCTAssertEqual("formInput", metadata["CreationSource"])
        assertNoHybridData(metadata)
        assertNoApplePayData(metadata)
    }
    
    func testMetadataGenerator_withNativeApplePaySource_containsCreationSourceData() {
        let metadata = getMetadata(.applePay)
        
        XCTAssertEqual("applePay", metadata["CreationSource"])
        assertApplePayData(metadata)
        assertNoHybridData(metadata)
    }
    
    func testMetadataGenerator_withNativeApplePaySource_containsApplePayData() {
        let metadata = getMetadata(.applePay)
        assertApplePayData(metadata)
    }
    
    func testMetadataGenerator_withHybridSingleLineSource_containsHybridData() {
        OloPayAPI.sdkWrapperInfo = OPSdkWrapperInfo(
            withMajorVersion: 1,
            withMinorVersion: 2,
            withBuildVersion: 3,
            withSdkBuildType: .internalBuild,
            withSdkPlatform: .reactNative
        )
        
        let metadata = getMetadata(.singleLineInput)
        assertHybridSdkKeysExist(metadata)
        assertNoApplePayData(metadata)
        
        XCTAssertEqual("1.2.3", metadata["HybridVersion"])
        XCTAssertEqual("internal", metadata["HybridBuildType"])
        XCTAssertEqual("reactNative", metadata["HybridPlatform"])
    }
    
    func testMetadataGenerator_withHybridFormSource_containsHybridData() {
        OloPayAPI.sdkWrapperInfo = OPSdkWrapperInfo(
            withMajorVersion: 2,
            withMinorVersion: 3,
            withBuildVersion: 4,
            withSdkBuildType: .publicBuild,
            withSdkPlatform: .capacitor
        )
        
        let metadata = getMetadata(.formInput)
        assertHybridSdkKeysExist(metadata)
        assertNoApplePayData(metadata)
        
        XCTAssertEqual("2.3.4", metadata["HybridVersion"])
        XCTAssertEqual("public", metadata["HybridBuildType"])
        XCTAssertEqual("capacitor", metadata["HybridPlatform"])
    }
    
    func testMetadataGenerator_withHybridApplePaySource_containsHybridData() {
        OloPayAPI.sdkWrapperInfo = OPSdkWrapperInfo(
            withMajorVersion: 1,
            withMinorVersion: 3,
            withBuildVersion: 5,
            withSdkBuildType: .internalBuild,
            withSdkPlatform: .flutter
        )
        
        let metadata = getMetadata(.applePay)
        assertHybridSdkKeysExist(metadata)
        assertApplePayData(metadata)
        
        XCTAssertEqual("1.3.5", metadata["HybridVersion"])
        XCTAssertEqual("internal", metadata["HybridBuildType"])
        XCTAssertEqual("flutter", metadata["HybridPlatform"])
    }

    func testMetadataGenerator_withNativeApplePaySource_withoutApplePayConstructor_containsNoApplePayValues() {
        let metadata = OPMetadataGenerator(.applePay).generate()
        assertApplePayKeysExist(metadata)
        
        XCTAssertEqual("", metadata["ApplePayMerchantId"])
        XCTAssertEqual("", metadata["DigitalWalletCompanyLabel"])
    }
    
    func testMetadataGenerator_withTestEnvironment_containsValidEnvironmentData() {
        OloPayAPI.environment = .test
        XCTAssertEqual("test", getMetadata(.singleLineInput)["Environment"])
    }
    
    func testMetadataGenerator_withProductionEnvironment_containsValidEnvironmentData() {
        OloPayAPI.environment = .production
        XCTAssertEqual("production", getMetadata(.singleLineInput)["Environment"])
    }
    
    func getMetadata (_ source: OPPaymentMethodSource) -> [String : String] {
        
        let generator = source != .applePay ?
            OPMetadataGenerator(source) :
            OPMetadataGenerator(applePayMerchantId: _applePayMerchantId, applePayCompanyLabel: _applePayCompanyLabel)
        
        let metadata = generator.generate()
        
        assertStaticMetadata(metadata)
        
        return metadata
    }
    
    func assertStaticMetadata(_ metadata: [String : String]) {
        XCTAssertTrue(metadata.keys.contains("CreationSource"))
        XCTAssertTrue(metadata.keys.contains("BuildType"))
        XCTAssertTrue(metadata.keys.contains("Version"))
        XCTAssertTrue(metadata.keys.contains("Platform"))
        XCTAssertTrue(metadata.keys.contains("OSVersion"))
        XCTAssertTrue(metadata.keys.contains("Environment"))
        
        
        guard let buildType = OPSdkBuildType.convert(from: OPSdkBuild.buildType) else {
            XCTFail("Expected 'buildType' to not be nil")
            return
        }
        XCTAssertEqual(buildType.description, metadata["BuildType"]?.lowercased())
        XCTAssertEqual(OPSdkVersion.version, metadata["Version"])
        XCTAssertEqual("ios", metadata["Platform"])
        XCTAssertEqual(UIDevice.current.systemVersion, metadata["OSVersion"])
    }
    
    func assertHybridSdkKeysExist(_ metadata: [String : String]) {
        XCTAssertTrue(metadata.keys.contains("HybridBuildType"))
        XCTAssertTrue(metadata.keys.contains("HybridPlatform"))
        XCTAssertTrue(metadata.keys.contains("HybridVersion"))
    }
    
    func assertNoApplePayData(_ metadata: [String : String]) {
        XCTAssertFalse(metadata.keys.contains("DigitalWalletCompanyLabel"))
        XCTAssertFalse(metadata.keys.contains("ApplePayEnvironment"))
    }

    func assertApplePayKeysExist(_ metadata: [String : String]) {
        XCTAssertTrue(metadata.keys.contains("ApplePayMerchantId"))
        XCTAssertTrue(metadata.keys.contains("DigitalWalletCompanyLabel"))
    }
    
    func assertApplePayData(_ metadata: [String : String]) {
        assertApplePayKeysExist(metadata)
        
        XCTAssertEqual("com.merchant.test", metadata["ApplePayMerchantId"])
        XCTAssertEqual("Test Company", metadata["DigitalWalletCompanyLabel"])
    }
    
    func assertNoHybridData(_ metadata: [String : String]) {
        XCTAssertFalse(metadata.keys.contains("HybridBuildType"))
        XCTAssertFalse(metadata.keys.contains("HybridPlatform"))
        XCTAssertFalse(metadata.keys.contains("HybridVersion"))
    }
}
