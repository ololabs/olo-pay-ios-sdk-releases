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

    let _applePayCompanyLabel = "Test"
    let _applePayCountryCode = "US"
    let _applePayEnvironment = OPEnvironment.test
    let _applePayMerchantId = "TestMerchant"
    
    override func setUpWithError() throws {
        OloPayAPI.sdkWrapperInfo = nil
        OloPayAPI.freshSetup = false
    }
    
    func testMetadataGenerator_withNativeSingleLineInputSource_containsCreationSourceData() {
        let metadata = getMetadata(OPPaymentMethodSource.singleLineInput)

        XCTAssertEqual(OPPaymentMethodSource.singleLineInput.description, metadata["CreationSource"])
        assertNoHybridData(metadata)
        assertNoApplePayData(metadata)
    }
    
    func testMetadataGenerator_withNativeFormLineInputSource_containsCreationSourceData() {
        let metadata = getMetadata(OPPaymentMethodSource.formInput)
        
        XCTAssertEqual(OPPaymentMethodSource.formInput.description, metadata["CreationSource"])
        assertNoHybridData(metadata)
        assertNoApplePayData(metadata)
    }
    
    func testMetadataGenerator_withNativeApplePaySource_containsCreationSourceData() {
        let metadata = getMetadata(OPPaymentMethodSource.applePay)
        
        XCTAssertEqual(OPPaymentMethodSource.applePay.description, metadata["CreationSource"])
        assertNoHybridData(metadata)
    }
    
//    func testMetadataGenerator_withNativeApplePaySource_containsApplePayData() {
//        // TODO: OLO-56324
//    }
    
    func testMetadataGenerator_withHybridSingleLineSource_containsHybridData() {
        OloPayAPI.sdkWrapperInfo = OPSdkWrapperInfo(withMajorVersion: 1, withMinorVersion: 2, withBuildVersion: 3, withSdkBuildType: OPSdkWrapperBuildType.internalBuild, withSdkPlatform: OPSdkWrapperPlatform.reactNative)
        
        let metadata = getMetadata(OPPaymentMethodSource.singleLineInput)
        assertHybridSdkKeysExist(metadata)
        assertNoApplePayData(metadata)
        
        XCTAssertEqual("1.2.3", metadata["HybridVersion"])
        XCTAssertEqual("Internal", metadata["HybridBuildType"])
        XCTAssertEqual("ReactNative", metadata["HybridPlatform"])
    }
    
    func testMetadataGenerator_withHybridFormSource_containsHybridData() {
        OloPayAPI.sdkWrapperInfo = OPSdkWrapperInfo(withMajorVersion: 2, withMinorVersion: 3, withBuildVersion: 4, withSdkBuildType: OPSdkWrapperBuildType.publicBuild, withSdkPlatform: OPSdkWrapperPlatform.capacitor)
        
        let metadata = getMetadata(OPPaymentMethodSource.formInput)
        assertHybridSdkKeysExist(metadata)
        assertNoApplePayData(metadata)
        
        XCTAssertEqual("2.3.4", metadata["HybridVersion"])
        XCTAssertEqual("Public", metadata["HybridBuildType"])
        XCTAssertEqual("Capacitor", metadata["HybridPlatform"])
    }
    
//    func testMetadataGenerator_withHybridApplePaySource_containsHybridData() {
//        // TODO: OLO-56324
//    }
//
//    func testMetadataGenerator_withNativeApplePaySource_withoutApplePayConfig_containsNoApplePayData() {
//        // TODO: OLO-56324
//    }
    
    func testMetadataGenerator_withTestEnvironment_containsValidEnvironmentData() {
        OloPayAPI.environment = OPEnvironment.test
        XCTAssertEqual("test", getMetadata(OPPaymentMethodSource.singleLineInput)["Environment"])
    }
    
    func testMetadataGenerator_withProductionEnvironment_containsValidEnvironmentData() {
        OloPayAPI.environment = OPEnvironment.production
        XCTAssertEqual("production", getMetadata(OPPaymentMethodSource.singleLineInput)["Environment"])
    }
    
    func testMetadataGenerator_withFreshSetup_containsValidSetupData() {
        OloPayAPI.freshSetup = true
        XCTAssertEqual("true", getMetadata(OPPaymentMethodSource.singleLineInput)["FreshInstall"])
    }
    func testMetadataGenerator_withoutFreshSetup_containsValidSetupData() {
        OloPayAPI.freshSetup = false
        XCTAssertEqual("false", getMetadata(OPPaymentMethodSource.singleLineInput)["FreshInstall"])
    }
    
    func getMetadata (_ source: OPPaymentMethodSource) -> [String: String] {
                
        let metadata = OPMetadataGenerator(source).generate()
        
        assertStaticMetadata(metadata)
        
        return metadata
    }
    
    func assertStaticMetadata(_ metadata: [String:String]) {
        XCTAssertTrue(metadata.keys.contains("CreationSource"))
        XCTAssertTrue(metadata.keys.contains("BuildType"))
        XCTAssertTrue(metadata.keys.contains("Version"))
        XCTAssertTrue(metadata.keys.contains("Platform"))
        XCTAssertTrue(metadata.keys.contains("OSVersion"))
        XCTAssertTrue(metadata.keys.contains("Environment"))
        XCTAssertTrue(metadata.keys.contains("FreshInstall"))
        
        XCTAssertEqual(OPStorageWrapper.getPListValue(of: "SDK Build Type", from: "Info", as: String.self), metadata["BuildType"])
        XCTAssertEqual(OPStorageWrapper.getPListValue(of: "SDK Build Version", from: "Info", as: String.self), metadata["Version"])
        XCTAssertEqual("iOS", metadata["Platform"])
        XCTAssertEqual(UIDevice.current.systemVersion, metadata["OSVersion"])
    }
    
    func assertHybridSdkKeysExist(_ metadata: [String: String]) {
        XCTAssertTrue(metadata.keys.contains("HybridBuildType"))
        XCTAssertTrue(metadata.keys.contains("HybridPlatform"))
        XCTAssertTrue(metadata.keys.contains("HybridVersion"))
    }
    
    func assertNoApplePayData(_ metadata: [String: String]) {
        XCTAssertFalse(metadata.keys.contains("DigitalWalletCompanyLabel"))
        XCTAssertFalse(metadata.keys.contains("ApplePayEnvironment"))
        XCTAssertFalse(metadata.keys.contains("ApplePayCountryCode"))
    }

    func assertNoHybridData(_ metadata: [String: String]) {
        XCTAssertFalse(metadata.keys.contains("HybridBuildType"))
        XCTAssertFalse(metadata.keys.contains("HybridPlatform"))
        XCTAssertFalse(metadata.keys.contains("HybridVersion"))
    }
}
