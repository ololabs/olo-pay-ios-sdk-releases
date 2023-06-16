//
//  OPSdkWrapperBuildType.swift
//  OloPaySDK
//
//  Created by Richard Dowdy on 6/1/23.
//

import Foundation

public enum OPSdkWrapperBuildType: Int, CustomStringConvertible {
    case internalBuild
    case publicBuild
    
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
