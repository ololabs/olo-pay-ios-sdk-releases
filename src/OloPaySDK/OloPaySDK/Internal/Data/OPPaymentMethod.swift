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
import PassKit

class OPPaymentMethod: NSObject, OPPaymentMethodProtocol {
    let _paymentMethod: STPPaymentMethod
    let _applePayCardDescription: String
    var _phoneticName: String
    var _billingAddress: OPAddress
    let _applePayConfig: OPApplePayConfiguration?

    @objc required init(
        paymentMethod: STPPaymentMethod,
        pkPayment: PKPayment? = nil,
        applePayConfig: OPApplePayConfiguration? = nil
    ) {
        _paymentMethod = paymentMethod
        _applePayConfig = applePayConfig
        
        _applePayCardDescription = pkPayment?.token.paymentMethod.displayName ?? ""
        
        _phoneticName = ""
        if _applePayConfig?.fullNameRequired ?? false {
            let firstName = pkPayment?.billingContact?.name?.phoneticRepresentation?.givenName ?? ""
            let lastName = pkPayment?.billingContact?.name?.phoneticRepresentation?.familyName ?? ""
            _phoneticName = "\(firstName) \(lastName)".trim()
        }
        
        let address = _paymentMethod.billingDetails?.address
        let addressRequired = applePayConfig?.fullBillingAddressRequired ?? false
        
        _billingAddress = OPAddress(
            street: addressRequired ? address?.line1 ?? "" : "",
            city: addressRequired ? address?.city ?? "" : "",
            state: addressRequired ? address?.state ?? "" : "",
            postalCode: address?.postalCode ?? "",
            countryCode: address?.country ?? _paymentMethod.card?.country ?? ""
        )
        
        super.init()
    }
    
    @objc var id: String {
        return _paymentMethod.stripeId
    }
    
    @objc var last4: String {
        return _paymentMethod.card?.last4 ?? ""
    }
    
    @objc var cardType: OPCardBrand { 
        return OPCardBrand.convert(from: _paymentMethod.card?.brand) 
    }
    
    @objc public var expirationMonth: NSNumber? { _paymentMethod.card?.expMonth as NSNumber? }

    @objc public var expirationYear: NSNumber? { _paymentMethod.card?.expYear as NSNumber? }
    
    @objc var postalCode: String { 
        return _billingAddress.postalCode
    }
    
    @objc var isApplePay: Bool {
        return _paymentMethod.card?.wallet?.type == .applePay
    }
    
    @objc var countryCode: String {
        return billingAddress.countryCode
    }
    
    @objc var environment: OPEnvironment {
        return _paymentMethod.liveMode ? .production : .test
    }
    
    @objc var applePayCardDescription: String {
        return _applePayCardDescription
    }
    
    @objc var email: String { 
        return _paymentMethod.billingDetails?.email ?? "" 
    }
    
    @objc var billingAddress: OPAddressProtocol {
        return _billingAddress
     }
    
    @objc var phoneNumber: String {
        return _paymentMethod.billingDetails?.phone ?? "" 
    }
    
    @objc var fullName: String {
        guard let applePayConfig = _applePayConfig, applePayConfig.fullNameRequired else {
            return ""
        }
       return _paymentMethod.billingDetails?.name ?? ""
    }
    
    @objc var fullPhoneticName: String {
        return _phoneticName
    }
    
    @objc public override var description: String {
        let properties = [
            String(format: "%@: %p", NSStringFromClass(OPPaymentMethod.self), self),
            "id = \(id)",
            "last4 = \(String(describing: last4))",
            "cardType = \(String(describing: cardType))",
            "expirationMonth = \(String(describing: expirationMonth))",
            "expirationYear = \(String(describing: expirationYear))",
            "postalCode = \(String(describing: billingAddress.postalCode))",
            "isApplePay = \(String(describing: isApplePay))",
            "countryCode = \(String(describing: billingAddress.countryCode))",
            "environment = \(environment.description)",
            "applePayCardDescription = \(String(describing: applePayCardDescription))",
            "email = \(String(describing: email))",
            "phoneNumber = \(String(describing: phoneNumber))",
            "fullName = \(String(describing: fullName))",
            "fullPhoneticName = \(String(describing: fullPhoneticName))",
            "billingAddress = \(String(describing: billingAddress))"
        ]
        
        return "<\(properties.joined(separator: ";\n"))>"
    }
}
