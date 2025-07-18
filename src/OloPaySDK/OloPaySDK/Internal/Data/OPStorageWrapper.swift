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
}
