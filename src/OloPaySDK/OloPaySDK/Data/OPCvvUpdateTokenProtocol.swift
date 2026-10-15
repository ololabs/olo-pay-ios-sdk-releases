// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPCvvUpdateTokenProtocol.swift
//  OloPaySDK
//
//  Created by Justin Anderson on 8/4/23.
//

import Foundation

/// Represents a single-use cvv update token used to submit a basket via Olo's Ordering API
/// when a saved card requires CVV revalidation
@objc public protocol OPCvvUpdateTokenProtocol : NSObjectProtocol {
    /// The id for the token
    @objc var id: String { get }
    
    /// The environment the token was created in
    @objc var environment: OPEnvironment { get }
}
