// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPStorage.swift
//  OloPaySDK
//
//  Created by Justin Anderson on 6/16/21.
//

import Foundation

class OPStorage {
    @OPStorageWrapper(key: "olopayapi_publishable_key_test", defaultValue: "")
    static var testPublishableKey: String
    
    @OPStorageWrapper(key: "olopayapi_publishable_key_prod", defaultValue: "")
    static var productionPublishableKey: String
    
    @OPStorageWrapper(key: "olopayapi_environment_key", defaultValue: OPEnvironment.production.description)
    static var environment: String
    
    static func getPublishableKey(environment: OPEnvironment) -> String {
        return environment == OPEnvironment.test ?
        testPublishableKey :
        productionPublishableKey
    }
    
    static func setPublishableKey(environment: OPEnvironment, value: String) {
        if(environment == OPEnvironment.test) {
            testPublishableKey = value
        } else {
            productionPublishableKey = value
        }
    }
}
