// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPAddress.swift
//  OloPaySDK
//
//  Created by Richard Dowdy on 1/17/25.
//

import Foundation
import PassKit

class OPAddress: NSObject, OPAddressProtocol {
    private var _street = ""
    private var _city = ""
    private var _state = ""
    private var _postalCode = ""
    private var _countryCode = ""
    
    internal var street: String {
        get { return _street }
    }
    
    internal var city: String {
        get { return _city }
    }
    
    internal var state: String {
        get { return _state }
    }
    
    internal var postalCode: String {
        get { return _postalCode }
    }
    
    internal var countryCode: String {
        get { return _countryCode }
    }
    
    internal init(
        street: String,
        city: String,
        state: String,
        postalCode: String,
        countryCode: String
    ) {
        _street = street
        _city = city
        _state = state
        _postalCode = postalCode
        _countryCode = countryCode
    }
    
    @objc public override var description: String {
        let properties = [
            String(format: "%@: %p", NSStringFromClass(OPAddress.self), self),
            "Street: \(street)",
            "City: \(city)",
            "State: \(state)",
            "Postal Code: \(postalCode)",
            "Country Code: \(countryCode)"
        ]
        
        return "<\(properties.joined(separator: ";\n"))>"
    }
}
