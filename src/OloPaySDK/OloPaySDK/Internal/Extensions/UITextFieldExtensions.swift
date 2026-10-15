// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  UITextFieldExtensions.swift
//  OloPaySDK
//

import UIKit

internal extension UITextField {
    func applyAutofillTraits(for field: OPCardField) {
        autocorrectionType = .no
        spellCheckingType = .no
        smartDashesType = .no
        smartQuotesType = .no
        smartInsertDeleteType = .no

        switch field {
        case .number:
            textContentType = .creditCardNumber
        case .expiration:
            // Expiration and security code content types don't exist before iOS 17
            if #available(iOS 17.0, *) {
                textContentType = .creditCardExpiration
            }
        case .cvv:
            if #available(iOS 17.0, *) {
                textContentType = .creditCardSecurityCode
            }
        case .postalCode:
            textContentType = .postalCode
            autocapitalizationType = .allCharacters
        case .unknown:
            break
        }
    }
}
