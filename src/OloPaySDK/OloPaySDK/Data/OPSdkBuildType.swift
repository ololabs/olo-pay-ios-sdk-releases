// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPSdkBuildType.swift
//  OloPaySDK
//
//  Created by Richard Dowdy on 6/1/23.
//

import Foundation

/// :nodoc:
public enum OPSdkBuildType: Int, CustomStringConvertible {
    /// :nodoc:
    case internalBuild
    /// :nodoc:
    case publicBuild
    
    /// :nodoc:
    public var description: String {
        switch self {
        case .internalBuild:
            return "internal"
        case .publicBuild:
            return "public"
        }
    }
    
    /// :nodoc:
    internal static func convert(from key: String) -> OPSdkBuildType? {
        if key.lowercased() == OPSdkBuildType.internalBuild.description {
            return OPSdkBuildType.internalBuild
        } else if key.lowercased() == OPSdkBuildType.publicBuild.description {
            return OPSdkBuildType.publicBuild
        }
        
        return nil
    }
}
