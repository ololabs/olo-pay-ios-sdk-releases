// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPCardState.swift
//  OloPaySDK
//
//  Created by Justin Anderson on 9/29/23.
//

import Foundation
import Stripe

internal class OPCardState {
    var _cardBrand = OPCardBrand.unknown
    var _postalCodeTextValid = false
    
    let fieldStates = [
        OPCardField.number: OPCardFieldState(),
        OPCardField.expiration: OPCardFieldState(),
        OPCardField.cvv: OPCardFieldState(),
        OPCardField.postalCode: OPCardFieldState()
    ]
    
    var cardNumber: OPCardFieldState {
        get { fieldStates[.number]! }
    }
    
    var expiration: OPCardFieldState {
        get { fieldStates[.expiration]! }
    }
    
    var cvv: OPCardFieldState {
        get { fieldStates[.cvv]! }
    }
    
    var postalCode: OPCardFieldState {
        get { fieldStates[.postalCode]! }
    }
    
    var postalCodeFieldValid: Bool {
        get { postalCodeEnabled ? _postalCodeTextValid : true }
    }
    
    var focusedField: OPCardField? {
        get {
            let fields = fieldStates.filter({ $0.value.isFirstResponder })
            return fields.first(where: { $0.value.isFirstResponder })?.key ?? nil
        }
    }
    
    var isValidCardBrand: Bool {
        get { return _cardBrand != .unknown && _cardBrand != .unsupported }
    }
    
    var isValid: Bool {
        get { fieldStates.filter({ !$0.value.isValid }).isEmpty }
    }
    
    static var errorMessageHandler: OPCardErrorMessageBlock? = nil
    var delegate: OPValidStateChangedDelegate? = nil
    
    var postalCodeEnabled = true {
        didSet { postalCode.isValid = postalCodeFieldValid }
    }
    
    func hasErrorMessage(_ ignoreUneditedFields: Bool) -> Bool {
        let errorFields = getErrorFields(ignoreUneditedFields: ignoreUneditedFields)
        return !errorFields.isEmpty
    }
    
    func getErrorMessage(_ ignoreUneditedFields: Bool = true) -> String {
        guard hasErrorMessage(ignoreUneditedFields) else {
            return ""
        }
        
        guard let errorHandler = OPCardState.errorMessageHandler else {
            return getDefaultError(ignoreUneditedFields)
        }
        
        // Return custom error messages
        return errorHandler(fieldStates as NSDictionary, _cardBrand, ignoreUneditedFields)
    }
    
    func onCardNumberChanged(newText: String, brand: OPCardBrand) {
        _cardBrand = brand
        
        onFieldChanged(
            .number,
            isEmpty: newText.isEmpty,
            isValid: isValidCardBrand && isValidCardNumber(newText),
            previousValidState: isValid)
    }
    
    func onExpirationChanged(expirationMonth: String, expirationYear: String) {
        onFieldChanged(
            .expiration,
            isEmpty: expirationMonth.isEmpty && expirationYear.isEmpty,
            isValid: isValidExpiration(expirationMonth, expirationYear),
            previousValidState: isValid)
    }
    
    func onCvvChanged(newText: String) {
        onFieldChanged(
            .cvv,
            isEmpty: newText.isEmpty,
            isValid: isValidCvv(newText),
            previousValidState: isValid)
    }
    
    func onPostalCodeChanged(newText: String) {
        onFieldChanged(
            .postalCode,
            isEmpty: newText.isEmpty,
            isValid: isValidPostalCode(newText),
            previousValidState: isValid)
    }
    
    private func onFieldChanged(_ field: OPCardField, isEmpty: Bool, isValid: Bool, previousValidState: Bool) {
        let fieldState = fieldStates[field]!
        
        fieldState.isEmpty = isEmpty
        if !isEmpty {
            fieldState.wasEdited = true
        }
        
        fieldState.isValid = isValid
        notifyValidStateChanged(previousValidState)
    }
    
    func onBecomeFirstResponder(field: OPCardField) {
        onResignFirstResponder()
        fieldStates[field]!.isFirstResponder = true
    }
    
    func onResignFirstResponder() {
        guard let focusedField = focusedField else {
            return
        }
        
        let previousFocusedField = fieldStates[focusedField]!
        
        // Prevent fields from entering error states if focus changes
        // prior to any text being entered in the field
        if previousFocusedField.wasEdited {
            previousFocusedField.wasFirstResponder = true
        }
        
        previousFocusedField.isFirstResponder = false
    }
    
    func reset() {
        let previousValidState = isValid
        
        fieldStates.forEach { state in
            state.value.reset()
        }
        
        _cardBrand = .unknown
        _postalCodeTextValid = false
        
        notifyValidStateChanged(previousValidState)
    }
    
    func isValidCardNumber(_ cardNumber: String) -> Bool {
        return STPCardValidator.validationState(forNumber: cardNumber, validatingCardBrand: true) == .valid
    }
    
    func isValidCvv(_ cvv: String) -> Bool {
        return STPCardValidator.validationState(
                forCVC: cvv,
                cardBrand: OPCardBrand.convert(from: _cardBrand)) == .valid
    }
    
    func isValidExpiration(_ expirationMonth: String, _ expirationYear: String) -> Bool {
        if STPCardValidator.validationState(forExpirationMonth: expirationMonth) != .valid {
            return false
        }
        
        return STPCardValidator.validationState(
                forExpirationYear: expirationYear,
                inMonth: expirationMonth) == .valid
    }
    
    func isValidPostalCode(_ postalCode: String) -> Bool {
        return isValidUsPostalCode(postalCode) || isValidCaPostalCode(postalCode)
    }
    
    func isValidUsPostalCode(_ postalCode: String) -> Bool {
        let regEx = #"^\s*[0-9]{5}(-[0-9]{4})?\s*$"#
        return postalCode.range(of: regEx, options: .regularExpression) != nil
    }
    
    func isValidCaPostalCode(_ postalCode: String) -> Bool {
        let regEx = #"^[ABCEGHJKLMNPRSTVXY][0-9][ABCEGHJKLMNPRSTVWXYZ]\s?[0-9][ABCEGHJKLMNPRSTVWXYZ][0-9]$"#
        let upperPostal = postalCode.uppercased()
        return upperPostal.range(of: regEx, options: .regularExpression) != nil
    }
    
    func notifyValidStateChanged(_ previousValidState: Bool) {
        if previousValidState != isValid {
            delegate?.validStateChanged(isValid: isValid)
        }
    }
    
    func getDefaultError(_ ignoreUneditedFields: Bool) -> String {
        var errorMessage = ""
        
        if isInvalidField(.number, ignoreUneditedFields) {
            if (cardNumber.isEmpty) {
                errorMessage = OPStrings.emptyCardNumberError
            } else if _cardBrand == .unsupported {
                errorMessage = OPStrings.unsupportedCardError
            } else {
                errorMessage = OPStrings.invalidCardNumberError
            }
        } else if isInvalidField(.expiration, ignoreUneditedFields) {
            errorMessage = expiration.isEmpty ? OPStrings.emptyExpirationError : OPStrings.invalidExpirationError
        } else if isInvalidField(.cvv, ignoreUneditedFields) {
            errorMessage = cvv.isEmpty ? OPStrings.emptyCvvError : OPStrings.invalidCvvError
        } else if isInvalidField(.postalCode, ignoreUneditedFields) {
            errorMessage = postalCode.isEmpty ? OPStrings.emptyPostalCodeError : OPStrings.invalidPostalCodeError
        }
        
        return errorMessage
    }
    
    internal func getErrorFields(ignoreUneditedFields: Bool) -> [OPCardField : OPCardFieldState] {
        return fieldStates.filter({ isInvalidField($0.key, ignoreUneditedFields) })
    }
    
    func isInvalidField(_ field: OPCardField, _ ignoreUneditedFields: Bool) -> Bool {
        let fieldState = fieldStates[field]!
        
        // Return error field regardless of edited/focused state
        if !ignoreUneditedFields {
            return !fieldState.isValid
        }
        
        // Only invalid if the field has also been edited and focused
        return !fieldState.isValid && fieldState.wasEdited && fieldState.wasFirstResponder
    }
}
