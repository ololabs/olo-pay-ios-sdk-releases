// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPPaymentMethodProtocol.swift
//  OloPaySDK
//
//  Created by Justin Anderson on 5/28/21.
//

import Foundation
import Stripe

/// Represents a payment method containing all information needed to submit a basket
/// via Olo's Ordering API
@objc public protocol OPPaymentMethodProtocol : NSObjectProtocol {
    /// The payment method id. This should be set to the token field when submitting a basket
    @objc var id: String { get }
    
    /// The last four digits of the card
    @objc var last4: String? { get }
    
    /// The issuer of the card (e.g. Visa, Mastercard, etc)
    @objc var cardType: OPCardBrand { get }
    
    /// Two-digit number representing the card's expiration month
    @objc var expirationMonth: NSNumber? { get }
    
    /// Four-digit number representing the card’s expiration year
    @objc var expirationYear: NSNumber? { get }
    
    /// ZIP or postal code
    @objc var postalCode: String? { get }
    
    /// Whether or not this payment method was created via ApplePay
    @objc var isApplePay: Bool { get }
    
    /// Country from the card in the payment method
    @objc var country: String? { get }
    
    /// The environment used to create the payment method
    @objc var environment: OPEnvironment { get }
}

