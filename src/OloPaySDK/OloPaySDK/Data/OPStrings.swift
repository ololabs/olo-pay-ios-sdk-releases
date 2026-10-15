// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPStrings.swift
//  OloPaySDK
//
//  Created by Justin Anderson on 7/20/21.
//

import Foundation

//TODO: Add localization support
/// Default error messages used by `OPPaymentCardDetailsView`
@objc public class OPStrings : NSObject {
    /// Default error message for an invalid card number
    @objc public static let invalidCardNumberError = "Your card's number is invalid"
    
    /// Default error message for an empty card number
    @objc public static let emptyCardNumberError = "Your card's number is missing"
    
    /// Default error message for an invalid expiration date
    @objc public static let invalidExpirationError = "Your card's expiration date is invalid"
    
    /// Default error message for an empty expiration date
    @objc public static let emptyExpirationError = "Your card's expiration date is missing"
    
    /// Default error message for an invalid cvv
    @objc public static let invalidCvvError = "Your card's security code is invalid"
    
    /// Default error message for an empty cvv
    @objc public static let emptyCvvError = "Your card's security code is missing"
    
    /// Default error message for an invalid postal code
    @objc public static let invalidPostalCodeError = "Your ZIP/postal code is invalid"
    
    /// Default error message for an empty postal code
    @objc public static let emptyPostalCodeError = "Your ZIP/postal code is missing"
    
    /// Default error mesage if the card number is valid but is not a supported type
    @objc public static let unsupportedCardError = "Your card type is not supported"
    
    /// Default error message for unknown/general card errors
    @objc public static let generalCardError = "Your card details are invalid"
    
    /// Default error message for an incomplete CVV field (used with `OPPaymentCardCvvView`)
    @objc public static let incompleteCvvError = "Your card's security code is incomplete"
    
    /// Deprecated: Use `invalidCvvError` instead
    @available(*, deprecated, renamed: "invalidCvvError")
    @objc public static let invalidCvcError = invalidCvvError
    
    /// Deprecated: Use `emptyCvvError` instead
    @available(*, deprecated, renamed: "emptyCvvError")
    @objc public static let emptyCvcError = emptyCvvError
    
    // INTERNAL STRINGS
    internal static let incorrectCvvTokenParamsType = "Params must be of type OPCvvTokenParams"
    internal static let numberPlaceholder = "4242424242424242"
    internal static let expirationPlaceholder = "MM/YY"
    internal static let cvvPlaceholder = "CVV"
    internal static let postalCodePlaceholder = "Postal Code"
    
    // Stripe Input Field Types
    internal static let stripeNumberField = "STPCardNumberInputTextField"
    internal static let stripeExiryField = "STPCardExpiryInputTextField"
    internal static let stripeCvvField = "STPCardCVCInputTextField"
    internal static let stripePostalCodeField = "STPPostalCodeInputTextField"
}
