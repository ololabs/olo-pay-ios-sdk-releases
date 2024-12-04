// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPPaymentMethod.swift
//  OloPaySDK
//
//  Created by Justin Anderson on 9/11/23.
//

import Foundation
import Stripe

class OPPaymentMethod: NSObject, OPPaymentMethodProtocol {
    var _paymentMethod: STPPaymentMethod
    
    @objc required init(paymentMethod: STPPaymentMethod) {
        _paymentMethod = paymentMethod
        super.init()
    }
    
    @objc public var id: String { _paymentMethod.stripeId }
    
    @objc public var last4: String? { _paymentMethod.card?.last4 }
    
    @objc public var cardType: OPCardBrand { OPCardBrand.convert(from: _paymentMethod.card?.brand) }
    
    @objc public var expirationMonth: NSNumber? { _paymentMethod.card?.expMonth as NSNumber? }
    
    @objc public var expirationYear: NSNumber? { _paymentMethod.card?.expYear as NSNumber? }
    
    @objc public var postalCode: String? { _paymentMethod.billingDetails?.address?.postalCode }
    
    @objc public var isApplePay: Bool { _paymentMethod.card?.wallet?.type == STPPaymentMethodCardWalletType.applePay }
    
    @objc public var country: String? { _paymentMethod.card?.country?.replacingOccurrences(of: "\"", with: "") }
    
    @objc public var environment: OPEnvironment { _paymentMethod.liveMode ? .production : .test }
    
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
            "country = \(String(describing: country))",
            "environment = \(environment.description)"
        ]
        
        return "<\(properties.joined(separator: "; "))>"
    }
}
