// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPCvvUpdateToken.swift
//  OloPaySDK
//
//  Created by Justin Anderson on 9/11/23.
//

import Foundation
import Stripe

class OPCvvUpdateToken: NSObject, OPCvvUpdateTokenProtocol {
    let _token: STPToken
    
    internal required init(_ token: STPToken) {
        _token = token
        super.init()
    }
    
    @objc public var id: String { _token.tokenId }
    
    @objc public var environment: OPEnvironment {
        return _token.livemode ? OPEnvironment.production : OPEnvironment.test
    }
    
    @objc public override var description: String {
        let properties = [
            String(format: "%@: %p", NSStringFromClass(OPCvvUpdateToken.self), self),
            "id = \(id)",
            "environment = \(String(describing: environment))"
        ]
        
        return "<\(properties.joined(separator: "; "))>"
    }
}
