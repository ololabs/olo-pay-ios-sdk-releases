// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPSdkWrapperInfo.swift
//  OloPaySDK
//
//  Created by Richard Dowdy on 6/1/23.
//

import Foundation

public class OPSdkWrapperInfo: NSObject {
    private let _majorVersion: Int
    private let _minorVersion: Int
    private let _buildVersion: Int
    private let _sdkBuildType: OPSdkWrapperBuildType
    private let _sdkPlatform: OPSdkWrapperPlatform
    
    public init (withMajorVersion majorVersion: Int, withMinorVersion minorVersion: Int, withBuildVersion buildVersion: Int, withSdkBuildType sdkBuildType: OPSdkWrapperBuildType, withSdkPlatform sdkPlatform: OPSdkWrapperPlatform) {
        _majorVersion = majorVersion
        _minorVersion = minorVersion
        _buildVersion = buildVersion
        _sdkBuildType = sdkBuildType
        _sdkPlatform = sdkPlatform
    }
    
    public var version: String {
        get {"\(_majorVersion).\(_minorVersion).\(_buildVersion)"}
    }
    
    public var buildType: String {
        get {_sdkBuildType.description}
    }
    
    public var platform: String {
        get {_sdkPlatform.description}
    }
}
