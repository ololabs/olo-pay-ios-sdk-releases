// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPSdkWrapperBuildType.swift
//  OloPaySDK
//
//  Created by Richard Dowdy on 6/1/23.
//

import Foundation

/// :nodoc:
public enum OPSdkWrapperBuildType: Int, CustomStringConvertible {
    /// :nodoc:
    case internalBuild
    /// :nodoc:
    case publicBuild
    
    /// :nodoc:
    public var description: String {
        switch self {
        case .internalBuild:
            return "Internal"
        case .publicBuild:
            return "Public"
        }
    }
    
    internal static func convert(from key: String) -> OPSdkWrapperBuildType {
        if key == OPSdkWrapperBuildType.internalBuild.description {
            return OPSdkWrapperBuildType.internalBuild
        }
        return OPSdkWrapperBuildType.publicBuild
    }
}
