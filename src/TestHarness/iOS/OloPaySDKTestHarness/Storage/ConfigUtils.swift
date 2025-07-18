// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  ConfigUtils.swift
//  OloPaySDKTestHarness
//
//  Created by Justin Anderson on 7/12/21.
//

import Foundation

class ConfigUtils {
    
    
    // Code for reading plist from within a framework adapted from
    // http://biercoff.com/reading-plist-resource-from-your-ios-framework-library/
    static func getStringPListValue(of key: String) -> String? {
        guard let path = Bundle.main.path(forResource: "Info", ofType: "plist"), let dictionary = NSDictionary(contentsOfFile: path) else {
            return nil
        }
        
        return dictionary.object(forKey: key) as? String
    }
    
    static func getBoolPListValue(of key: String) -> Bool? {
        guard let stringValue = getStringPListValue(of: key), let keyValue = Bool(stringValue) else {
            return nil
        }
        
        return keyValue
    }
    
    static func getUInt64PListValue(of key: String) -> UInt64? {
        guard let stringValue = getStringPListValue(of: key), let keyValue = UInt64(stringValue) else {
            return nil
        }

        return keyValue
    }
    
    static func getUIntPListValue(of key: String) -> UInt? {
        guard let stringValue = getStringPListValue(of: key), let keyValue = UInt(stringValue) else {
            return nil
        }

        return keyValue
    }
}
