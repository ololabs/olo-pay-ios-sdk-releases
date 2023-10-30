// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPStorageWrapper.swift
//  OloPaySDK
//
//  Created by Justin Anderson on 6/11/21.
//

import Foundation

@propertyWrapper
class OPStorageWrapper {
    private let key: String
    private let defaultValue: String

    init(key: String, defaultValue: String) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: String {
        get { UserDefaults.standard.string(forKey: key) ?? defaultValue }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }

    // Code for reading plist from within a framework adapted from
    // http://biercoff.com/reading-plist-resource-from-your-ios-framework-library/
    static func getPListValue<T: Any>(
        of key: String,
        from resourceName: String,
        as type: T.Type) -> T?
    {
        let bundle = Bundle(for: self)
        guard let pListValue = getPlistValueFromBundle(of: key, from: resourceName, in: bundle, as: type) else {
            //Workaround to read bundle resources for CocoaPods
            guard let resourceBundleUrl = bundle.url(forResource: "OloPaySDK", withExtension: "bundle") else {
                return nil
            }
            
            guard let resourceBundle = Bundle(url: resourceBundleUrl) else {
                return nil
            }
            
            return getPlistValueFromBundle(of: key, from: resourceName, in: resourceBundle, as: type)
        }
        
        return pListValue
    }

    private static func getPlistValueFromBundle<T: Any>(
        of key: String,
        from resourceName: String,
        in bundle: Bundle,
        as type: T.Type) -> T?
    {
        guard let URL = bundle.url(forResource: resourceName, withExtension: "plist") else {
            print("Unable to find \(resourceName).plist resource file")
            return nil
        }
         
        guard let fileContent = NSDictionary(contentsOf: URL) as? [String: Any] else {
            print("Unable to read \(key) content and convert it into [String: Any]")
            return nil
        }
        return fileContent[key] as? T
    }
}
