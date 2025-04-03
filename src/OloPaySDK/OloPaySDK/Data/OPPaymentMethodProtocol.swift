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
    @objc var last4: String { get }
    
    /// The issuer of the card (e.g. Visa, Mastercard, etc)
    @objc var cardType: OPCardBrand { get }
    
    /// Two-digit number representing the card's expiration month
    @objc var expirationMonth: NSNumber? { get }
    
    /// Four-digit number representing the card’s expiration year
    @objc var expirationYear: NSNumber? { get }
    
    /// Convenience property for accessing the ZIP or postal code, equivalent to `billingAddress.postalCode`
    @objc var postalCode: String { get }

    /// Whether or not this payment method was created via ApplePay
    @objc var isApplePay: Bool { get }

    /// Convenience property for accessing the country code, equivalent to `billingAddress.countryCode`
    @objc var countryCode: String { get }  
    
    /// The environment used to create the payment method
    @objc var environment: OPEnvironment { get }
    
    /// The description of the card, as provided by Apple. This is commonly the payment network and the last four digits of the payment
    /// account number. Only available for Apple Pay payment methods (see `isApplePay`). For other payment methods, this property will be an empty string.
    @objc var applePayCardDescription: String { get }
    
    /// The billing address associated with the transaction. The country code and postal code fields will always be set.
    /// Other fields will only be set for Apple Pay payment methods (see `isApplePay`) with `OPApplePayConfiguration.fullBillingAddressRequired` set to true
    @objc var billingAddress: OPAddressProtocol { get }
    
    /// The email address associated with the transaction, or an empty string if unavailable. 
    /// Will only be provided for Apple Pay payment methods (see isApplePay) with OPApplePayConfiguration.emailRequired set to true.
    @objc var email: String { get }
    
    /// The phone number associated with the transaction, or an empty string if unavailable. Will only be provided for Apple Pay 
    /// payment methods (see `isApplePay`) with `OPApplePayConfiguration.phoneNumberRequired` set to true
    @objc var phoneNumber: String { get }
    
    /// The full name associated with the transaction, or an empty string if unavailable. Will only be provided for Apple Pay 
    /// payment methods (see `isApplePay`) with `OPApplePayConfiguration.fullNameRequired` set to true.
    @objc var fullName: String { get }
    
    /// The phonetic name associated with the transaction. Will only be provided for Apple Pay payment methods (see `isApplePay`) and if
    /// `OPApplePayConfiguration.fullNameRequired` was set to true. In all other scenarios this will be an empty string.

    /// The full phonetic name associated with the transaction, or an empty string if unavailable. Will only be provided for Apple Pay 
    /// payment methods (see `isApplePay`) with `OPApplePayConfiguration.fullNameRequired` set to true, and if the user has set up a phonetic name.
    @objc var fullPhoneticName: String { get }
}

