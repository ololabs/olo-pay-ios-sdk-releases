// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPEnvironment.swift
//  OloPaySDK
//
//  Created by Justin Anderson on 8/9/22.
//

import Foundation
import ImageIO

/// Enum indicating the environment that should be used for the Olo Pay SDK
@objc public enum OPEnvironment : Int, CustomStringConvertible {
    /// Production environment
    case production
    /// Test environment
    case test
    
    public var description: String {
        switch self {
        case .production:
            return "production"
        case .test:
            return "test"
        }
    }
    
    internal static func convert(from key: String) -> OPEnvironment {
        if key.lowercased() == OPEnvironment.test.description {
            return OPEnvironment.test
        }

        return OPEnvironment.production
    }
    
    internal var publishableKeyUrl: URL? {
        switch self {
        case .production:
            return URL(string: "https://static.olocdn.net/web-client/olo-pay/keys/prod.json")
        case .test:
            return URL(string: "https://static.olocdn.net/web-client/olo-pay/keys/dev.json")
        }
    }
}
