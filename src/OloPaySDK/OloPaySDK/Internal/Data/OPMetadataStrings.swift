// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPMetadataStrings.swift
//  OloPaySDK
//
//  Created by Richard Dowdy on 5/30/23.
//

import Foundation

class OPMetadataStrings: NSObject {
    // THESE KEYS EXIST FOR ALL GENERATED METADATA
    public static let creationSourceKey = "CreationSource"
    public static let sdkBuildTypeKey = "BuildType"
    public static let sdkVersionKey = "Version"
    public static let sdkPlatformKey = "Platform"
    public static let iosApiVersionKey = "OSVersion"
    public static let sdkEnvironmentKey = "Environment"
    public static let sdkFreshInstallKey = "FreshInstall"
    
    // THESE KEYS ONLY EXIST IF HYBRID SDK DATA IS SET
    public static let hybridSdkBuildTypeKey = "HybridBuildType"
    public static let hybridSdkPlatformKey = "HybridPlatform"
    public static let hybridSdkVersionKey = "HybridVersion"
    
    // THESE KEYS ONLY EXIST IF THE SOURCE IS APPLE PAY
    public static let digitalWalletCompanyLabelKey = "DigitalWalletCompanyLabel"
    public static let applePayMerchantIdKey = "ApplePayMerchantId"
    
    // NOT A FIELD - A STRING FOR THE PLATFORM 
    public static let sdkPlatformValue = "iOS"
    
    public static let unknownValue = "Unknown"
}
