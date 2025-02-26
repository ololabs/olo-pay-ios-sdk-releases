// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPAddressProtocol.swift
//  OloPaySDK
//
//  Created by Richard Dowdy on 1/17/25.
//

import Foundation

/// Represents an address.
@objc public protocol OPAddressProtocol : NSObjectProtocol {
    /// The conbined contents of the addressee's Street and Apt. or Suite billing address fields
    @objc var street: String { get }

    /// The city of the addressee
    @objc var city: String { get }

    /// The state of the addressee
    @objc var state: String { get }

    /// The postal or zip code
    @objc var postalCode: String { get }

    /// The two digit ISO country code using ISO 3166-1 alpha-2 standard
    @objc var countryCode: String { get }
}
