// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPPaymentMethod.swift
//  OloPaySDK
//
//  Created by Justin Anderson on 5/28/21.
//

import Foundation
import Stripe

/// Protocol for mocking/testing purposes. See `OPPaymentMethod` for documentation
@objc public protocol OPPaymentMethodProtocol : NSObjectProtocol {
    /// See `OPPaymentMethod.id` for documentation
    @objc var id: String { get }
    
    /// See `OPPaymentMethod.last4` for documentation
    @objc var last4: String? { get }
    
    /// See `OPPaymentMethod.cardType` for documentation
    @objc var cardType: OPCardBrand { get }
    
    /// See `OPPaymentMethod.expirationMonth` for documentation
    @objc var expirationMonth: NSNumber? { get }
    
    /// See `OPPaymentMethod.expirationYear` for documentation
    @objc var expirationYear: NSNumber? { get }
    
    /// See `OPPaymentMethod.postalCode` for documentation
    @objc var postalCode: String? { get }
    
    /// See `OPPaymentMethod.isApplePay` for documentation
    @objc var isApplePay: Bool { get }
    
    /// See `OPPaymentMethod.country` for documentation
    @objc var country: String? { get }
}

/// Represents a payment method containing all information needed to submit a basket
/// via Olo's Ordering API
@objc public class OPPaymentMethod: NSObject, OPPaymentMethodProtocol {
    var _paymentMethod: STPPaymentMethod
    
    @objc required init(paymentMethod: STPPaymentMethod) {
        _paymentMethod = paymentMethod
        super.init()
    }
    
    /// The payment method id. This should be set to the token field when submitting a basket
    @objc public var id: String { _paymentMethod.stripeId }
    
    /// The last four digits of the card
    @objc public var last4: String? { _paymentMethod.card?.last4 }
    
    /// The issuer of the card (e.g. Visa, Mastercard, etc)
    @objc public var cardType: OPCardBrand { OPCardBrand.convert(from: _paymentMethod.card?.brand) }
    
    /// Two-digit number representing the card's expiration month
    @objc public var expirationMonth: NSNumber? { _paymentMethod.card?.expMonth as NSNumber? }
    
    /// Four-digit number representing the card’s expiration year
    @objc public var expirationYear: NSNumber? { _paymentMethod.card?.expYear as NSNumber? }
    
    /// ZIP or postal code
    @objc public var postalCode: String? { _paymentMethod.billingDetails?.address?.postalCode }
    
    /// Whether or not this payment method was created via ApplePay
    @objc public var isApplePay: Bool { _paymentMethod.card?.wallet?.type == STPPaymentMethodCardWalletType.applePay }
    
    /// Country from the card in the payment method
    @objc public var country: String? { _paymentMethod.card?.country?.replacingOccurrences(of: "\"", with: "") }
    
    /// A string representation of this class
    @objc public override var description: String {
        let properties = [
            String(format: "%@: %p", NSStringFromClass(OPPaymentMethod.self), self),
            "id = \(id)",
            "last4 = \(String(describing: last4))",
            "cardType = \(String(describing: cardType))",
            "expirationMonth = \(String(describing: expirationMonth))",
            "expirationYear = \(String(describing: expirationYear))",
            "postalCode = \(String(describing: postalCode))",
            "isApplePay = \(String(describing: isApplePay))",
            "country = \(String(describing: country))"
        ]
        
        return "<\(properties.joined(separator: "; "))>"
    }
}
