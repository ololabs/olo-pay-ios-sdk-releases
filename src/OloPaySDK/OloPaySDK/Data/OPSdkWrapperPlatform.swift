// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPSdkWrapperPlatform.swift
//  OloPaySDK
//
//  Created by Richard Dowdy on 6/1/23.
//

import Foundation

/// :nodoc:
public enum OPSdkWrapperPlatform: Int, CustomStringConvertible {
    /// :nodoc:
    case reactNative
    /// :nodoc:
    case capacitor
    /// :nodoc:
    case flutter
    
    /// :nodoc:
    public var description: String {
        switch self {
        case .reactNative:
            return "reactNative"
        case .capacitor:
            return "capacitor"
        case .flutter:
            return "flutter"
        }
    }
    
    internal static func convert(from key: String) -> OPSdkWrapperPlatform {
        switch key {
        case OPSdkWrapperPlatform.reactNative.description:
            return OPSdkWrapperPlatform.reactNative
        case OPSdkWrapperPlatform.capacitor.description:
            return OPSdkWrapperPlatform.capacitor
        default:
            return OPSdkWrapperPlatform.flutter
        }
    }
}
