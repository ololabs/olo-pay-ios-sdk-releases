// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPPaymentCardDetailsTextFieldInternal.swift
//  OloPaySDK
//
//  Created by Justin Anderson on 5/18/21.
//

import Foundation
import Stripe
import UIKit

protocol OPPaymentCardDetailsViewInternalDelegate: NSObjectProtocol {
    func paymentCardDetailsViewDidChange(_ cardDetails: OPPaymentCardDetailsInternalView)

    func paymentCardDetailsViewDidBeginEditing(_ cardDetails: OPPaymentCardDetailsInternalView)

    func paymentCardDetailsViewDidEndEditing(_ cardDetails: OPPaymentCardDetailsInternalView)

    func paymentCardDetailsViewFieldDidBeginEditing(_ cardDetails: OPPaymentCardDetailsInternalView, field: OPCardField)

    func paymentCardDetailsViewFieldDidEndEditing(_ cardDetails: OPPaymentCardDetailsInternalView, field: OPCardField)
}

//Subclass of STPPaymentCardTextField to allow customization of CVC, Card, and Error images
class OPPaymentCardDetailsInternalView: STPPaymentCardTextField, STPPaymentCardTextFieldDelegate {
    @objc public override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.delegate = self
    }

    internal var cardDetailsDelegate: OPPaymentCardDetailsViewInternalDelegate?

    internal func getPaymentMethodParams() -> STPPaymentMethodParams {
        let result = STPPaymentMethodParams()
        result.card = self.cardParams
        result.type = .card
        
        let address = STPPaymentMethodAddress()
        address.postalCode = postalCode
        
        let billingDetails = STPPaymentMethodBillingDetails()
        billingDetails.address = address
        
        result.billingDetails = billingDetails
        
        return result
    }

    // Closure property to change CVC image handler
    static var cvcImageClosure: OPCardBrandImageBlock {
        get { _cvcImageClosure }
        set { _cvcImageClosure = newValue }
    }

    // Closure property to change brand image handler
    static var brandImageClosure: OPCardBrandImageBlock {
        get { _brandImageClosure }
        set { _brandImageClosure = newValue }
    }

    // Closure property to change error image handler
    static var errorImageClosure: OPCardBrandImageBlock {
        get { _errorImageClosure }
        set { _errorImageClosure = newValue }
    }

    // Default CVC image handler that uses Stripe's native images
    private static var _cvcImageClosure: OPCardBrandImageBlock =
        { brand in STPPaymentCardTextField.cvcImage(for: OPCardBrand.convert(from: brand)) }

    // Default brand image handler that uses Stripe's native images
    private static var _brandImageClosure: OPCardBrandImageBlock =
        { brand in STPPaymentCardTextField.brandImage(for: OPCardBrand.convert(from: brand)) }

    //Default error image handler that uses Stripe's native images
    private static var _errorImageClosure: OPCardBrandImageBlock =
        { brand in STPPaymentCardTextField.errorImage(for: OPCardBrand.convert(from: brand)) }

    // Override to allow for cvc image customization
    @objc(cvcImageForCardBrand:) override class func cvcImage(for cardBrand: STPCardBrand) -> UIImage?
        { _cvcImageClosure(OPCardBrand.convert(from: cardBrand)) }

    // Override to allow for brand image customization
    @objc(brandImageForCardBrand:) override class func brandImage(for cardBrand: STPCardBrand) -> UIImage?
        { _brandImageClosure(OPCardBrand.convert(from: cardBrand)) }

    // Override to allow for error image customization
    @objc(errorImageForCardBrand:) override class func errorImage(for cardBrand: STPCardBrand) -> UIImage?
        { _errorImageClosure(OPCardBrand.convert(from: cardBrand)) }

    // STPPaymentCardTedtFieldDelegate
    @objc func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
        cardDetailsDelegate?.paymentCardDetailsViewDidChange(self)
    }

    @objc func paymentCardTextFieldDidBeginEditing(_ textField: STPPaymentCardTextField) {
        cardDetailsDelegate?.paymentCardDetailsViewDidBeginEditing(self)
    }

    @objc func paymentCardTextFieldDidEndEditing(_ textField: STPPaymentCardTextField) {
        cardDetailsDelegate?.paymentCardDetailsViewDidEndEditing(self)
    }

    @objc func paymentCardTextFieldDidBeginEditingNumber(_ textField: STPPaymentCardTextField) {
        cardDetailsDelegate?.paymentCardDetailsViewFieldDidBeginEditing(self, field: OPCardField.number)
    }

    @objc func paymentCardTextFieldDidEndEditingNumber(_ textField: STPPaymentCardTextField) {
        cardDetailsDelegate?.paymentCardDetailsViewFieldDidEndEditing(self, field: OPCardField.number)
    }

    @objc func paymentCardTextFieldDidBeginEditingCVC(_ textField: STPPaymentCardTextField) {
        cardDetailsDelegate?.paymentCardDetailsViewFieldDidBeginEditing(self, field: OPCardField.cvc)
    }

    @objc func paymentCardTextFieldDidEndEditingCVC(_ textField: STPPaymentCardTextField) {
        cardDetailsDelegate?.paymentCardDetailsViewFieldDidEndEditing(self, field: OPCardField.cvc)
    }

    @objc func paymentCardTextFieldDidBeginEditingExpiration(_ textField: STPPaymentCardTextField) {
        cardDetailsDelegate?.paymentCardDetailsViewFieldDidBeginEditing(self, field: OPCardField.expiration)
    }

    @objc func paymentCardTextFieldDidEndEditingExpiration(_ textField: STPPaymentCardTextField) {
        cardDetailsDelegate?.paymentCardDetailsViewFieldDidEndEditing(self, field: OPCardField.expiration)
    }

    @objc func paymentCardTextFieldDidBeginEditingPostalCode(_ textField: STPPaymentCardTextField) {
        cardDetailsDelegate?.paymentCardDetailsViewFieldDidBeginEditing(self, field: OPCardField.postalCode)
    }

    @objc func paymentCardTextFieldDidEndEditingPostalCode(_ textField: STPPaymentCardTextField) {
        cardDetailsDelegate?.paymentCardDetailsViewFieldDidEndEditing(self, field: OPCardField.postalCode)
    }
}
