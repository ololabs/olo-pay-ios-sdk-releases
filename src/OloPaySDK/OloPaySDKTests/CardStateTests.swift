// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  CardStateTests.swift
//  OloPaySDKTests
//
//  Created by Justin Anderson on 9/29/23.
//

import XCTest
@testable import OloPaySDK

final class CardStateTests: XCTestCase {
    lazy var _cardState: OPCardState? = nil
    var cardState: OPCardState {
        get { _cardState! }
    }
    
    override func setUpWithError() throws {
        _cardState = OPCardState()
    }

    override func tearDownWithError() throws {
        OPCardState.errorMessageHandler = nil
    }

    func testConstructor_validInitialState() {
        XCTAssertFalse(cardState.isValid)
        XCTAssertTrue(cardState.postalCodeEnabled)
        XCTAssertFalse(cardState._postalCodeTextValid)
        XCTAssertEqual(OPCardBrand.unknown, cardState._cardBrand)
    }
    
    func testFocusedField_withoutFocusedFields_returnsNil() {
        XCTAssertNil(cardState.focusedField)
    }
    
    func testFocusedField_withFocusedField_returnsFocusedField() {
        cardState.expiration.isFirstResponder = true
        XCTAssertEqual(OPCardField.expiration, cardState.focusedField)
    }
    
    func testIsValid_inInitialState_returnsFalse() {
        XCTAssertFalse(cardState.isValid)
    }
    
    func testIsValid_withAllFieldsValid_returnsTrue() {
        cardState.fieldStates.forEach({$0.value.isValid = true})
        XCTAssertTrue(cardState.isValid)
    }
    
    func testIsValid_withInvalidField_returnsFalse() {
        let fieldStates = cardState.fieldStates
        fieldStates.forEach({$0.value.isValid = true})
        
        fieldStates.forEach({ fieldState in
            fieldState.value.isValid = false
            XCTAssertFalse(cardState.isValid)
            fieldState.value.isValid = true
        })
    }
    
    func testPostalCodeFieldValid_postalCodeNotEnabled_fieldStateInvalid_returnsTrue() {
        cardState.postalCode.isValid = false
        cardState.postalCodeEnabled = false
        XCTAssertTrue(cardState.postalCodeFieldValid)
    }
    
    func testPostalCodeFieldValid_postalCodeEnabled_fieldStateValid_returnsTrue() {
        cardState.postalCode.isValid = true
        cardState._postalCodeTextValid = true
        cardState.postalCodeEnabled = true
        XCTAssertTrue(cardState.postalCodeFieldValid)
    }
    
    func testPostalCodeFieldValid_postalCodeEnabled_fieldStateNotValid_returnsFalse() {
        cardState.postalCode.isValid = false
        cardState.postalCodeEnabled = true
        XCTAssertFalse(cardState.postalCodeFieldValid)
    }
    
    func testIsValidCardBrand_cardBrandInvalid_returnsFalse() {
        cardState._cardBrand = .unknown
        XCTAssertFalse(cardState.isValidCardBrand)
        
        cardState._cardBrand = .unsupported
        XCTAssertFalse(cardState.isValidCardBrand)
    }
    
    func testIsValidCardBrand_cardBrandValid_returnsTrue() {
        cardState._cardBrand = .visa
        XCTAssertTrue(cardState.isValidCardBrand)
        
        cardState._cardBrand = .amex
        XCTAssertTrue(cardState.isValidCardBrand)
        
        cardState._cardBrand = .mastercard
        XCTAssertTrue(cardState.isValidCardBrand)
        
        cardState._cardBrand = .discover
        XCTAssertTrue(cardState.isValidCardBrand)
    }
    
    func testHasErrorMessage_notIgnoreUneditedFields_withInvalidField_returnsTrue() {
        let invalidField = OPCardField.cvv
        
        cardState.fieldStates.forEach {
            $0.value.isValid = $0.key != invalidField
            $0.value.wasEdited = true
            $0.value.wasFirstResponder = true
        }
        
        XCTAssertTrue(cardState.hasErrorMessage(false))
    }
    
    func testHasErrorMessage_notIgnoreUneditedFields_withoutInvalidField_returnsFalse() {
        cardState.fieldStates.forEach {
            $0.value.isValid = true
        }
        
        XCTAssertFalse(cardState.hasErrorMessage(false))
    }
    
    func testHasErrorMessage_ignoreUneditedFields_withInvalidEditedField_returnsTrue() {
        let invalidField = OPCardField.expiration
        
        cardState.fieldStates.forEach {
            $0.value.isValid = $0.key != invalidField
            $0.value.wasEdited = true
            $0.value.wasFirstResponder = true
        }
        
        XCTAssertTrue(cardState.hasErrorMessage(true))
    }
    
    func testHasErrorMessage_ignoreUneditedFields_withInvalidUneditedField_returnsFalse() {
        let invalidField = OPCardField.number
        
        cardState.fieldStates.forEach {
            $0.value.isValid = $0.key != invalidField
        }
        
        XCTAssertFalse(cardState.hasErrorMessage(true))
    }
    
    func testGetErrorMessage_withoutCustomErrors_invalidNumber_returnsDefaultErrors() {
        cardState.fieldStates.forEach {
            $0.value.isValid = true
        }
        
        cardState.cardNumber.isValid = false
        cardState.cardNumber.isEmpty = true
        XCTAssertEqual(OPStrings.emptyCardNumberError, cardState.getErrorMessage(false))
        
        cardState.cardNumber.isEmpty = false
        XCTAssertEqual(OPStrings.invalidCardNumberError, cardState.getErrorMessage(false))
        
        cardState._cardBrand = .unknown
        XCTAssertEqual(OPStrings.invalidCardNumberError, cardState.getErrorMessage(false))
        
        cardState._cardBrand = .unsupported
        XCTAssertEqual(OPStrings.unsupportedCardError, cardState.getErrorMessage(false))
    }
    
    func testGetErrorMessage_withoutCustomErrors_invalidExpiration_returnsDefaultErrors() {
        cardState.fieldStates.forEach {
            $0.value.isValid = true
        }
        
        cardState.expiration.isValid = false
        cardState.expiration.isEmpty = true
        XCTAssertEqual(OPStrings.emptyExpirationError, cardState.getErrorMessage(false))
        
        cardState.expiration.isEmpty = false
        XCTAssertEqual(OPStrings.invalidExpirationError, cardState.getErrorMessage(false))
    }
    
    func testGetErrorMessage_withoutCustomErrors_invalidCvv_returnsDefaultErrors() {
        cardState.fieldStates.forEach {
            $0.value.isValid = true
        }
        
        cardState.cvv.isValid = false
        cardState.cvv.isEmpty = true
        XCTAssertEqual(OPStrings.emptyCvvError, cardState.getErrorMessage(false))
        
        cardState.cvv.isEmpty = false
        XCTAssertEqual(OPStrings.invalidCvvError, cardState.getErrorMessage(false))
    }
    
    func testGetErrorMessage_withoutCustomErrors_invalidPostalCode_returnsDefaultErrors() {
        cardState.fieldStates.forEach {
            $0.value.isValid = true
        }
        
        cardState.postalCode.isValid = false
        cardState.postalCode.isEmpty = true
        XCTAssertEqual(OPStrings.emptyPostalCodeError, cardState.getErrorMessage(false))
        
        cardState.postalCode.isEmpty = false
        XCTAssertEqual(OPStrings.invalidPostalCodeError, cardState.getErrorMessage(false))
    }
    
    func testGetErrorMessage_withCustomErrors_returnsCustomError() {
        OPCardState.errorMessageHandler = customErrorMessageHandler(_:_:_:)
        cardState.cardNumber.isValid = false
        
        XCTAssertEqual("Custom Error", cardState.getErrorMessage(false))
    }
    
    func testOnCardNumberChanged_cardBrandSet() {
        XCTAssertEqual(OPCardBrand.unknown, cardState._cardBrand)
        
        cardState.onCardNumberChanged(newText: "", brand: .visa)
        XCTAssertEqual(OPCardBrand.visa, cardState._cardBrand)
    }
    
    func testOnFieldChanged_textEmpty_fieldEmptyAndNotEdited() {
        cardState.onCardNumberChanged(newText: "", brand: .unknown)
        cardState.onExpirationChanged(expirationMonth: "", expirationYear: "")
        cardState.onCvvChanged(newText: "")
        cardState.onPostalCodeChanged(newText: "")
        
        cardState.fieldStates.forEach {
            XCTAssertTrue($0.value.isEmpty)
            XCTAssertFalse($0.value.wasEdited)
        }
    }
    
    func testOnFieldChanged_textNotEmpty_fieldEditedAndNotEmpty() {
        cardState.onCardNumberChanged(newText: "Foo", brand: .unknown)
        cardState.onExpirationChanged(expirationMonth: "Foo", expirationYear: "Bar")
        cardState.onCvvChanged(newText: "Foo")
        cardState.onPostalCodeChanged(newText: "Bar")
        
        cardState.fieldStates.forEach {
            XCTAssertFalse($0.value.isEmpty)
            XCTAssertTrue($0.value.wasEdited)
        }
    }
    
    func testOnFieldChanged_fieldStartsEdited_textEmpty_fieldStillEdited() {
        cardState.fieldStates.forEach {
            $0.value.wasEdited = true
        }
        
        cardState.onCardNumberChanged(newText: "", brand: .unknown)
        cardState.onExpirationChanged(expirationMonth: "", expirationYear: "")
        cardState.onCvvChanged(newText: "")
        cardState.onPostalCodeChanged(newText: "")
        
        cardState.fieldStates.forEach {
            XCTAssertTrue($0.value.wasEdited)
        }
    }
    
    func testOnFieldChanged_isValidToggledTrue_delegateCalled() {
        let invalidField = OPCardField.postalCode
        
        cardState.fieldStates.forEach {
            $0.value.isValid = $0.key != invalidField
        }
        
        let delegate = MockValidStateChangedDelegate()
        cardState.delegate = delegate
        
        XCTAssertFalse(cardState.isValid)
        cardState.onPostalCodeChanged(newText: "55056")
        
        XCTAssertTrue(cardState.isValid)
        XCTAssertTrue(delegate.validStateChangedCalled)
        XCTAssertNotNil(delegate.validStateChangedParameter)
        XCTAssertTrue(delegate.validStateChangedParameter!)
    }
    
    func testOnFieldChanged_isValidToggledFalse_delegateCalled() {
        cardState.fieldStates.forEach {
            $0.value.isValid = true
        }
        
        let delegate = MockValidStateChangedDelegate()
        cardState.delegate = delegate
        
        XCTAssertTrue(cardState.isValid)
        cardState.onCardNumberChanged(newText: "", brand: .visa)
        
        XCTAssertFalse(cardState.isValid)
        XCTAssertTrue(delegate.validStateChangedCalled)
        XCTAssertNotNil(delegate.validStateChangedParameter)
        XCTAssertFalse(delegate.validStateChangedParameter!)
    }
    
    func testOnFieldChanged_isValidNotToggled_delegateNotCalled() {
        cardState.fieldStates.forEach {
            $0.value.isValid = true
        }
        
        let delegate = MockValidStateChangedDelegate()
        cardState.delegate = delegate
        
        XCTAssertTrue(cardState.isValid)
        cardState.onPostalCodeChanged(newText: "12345")
        
        XCTAssertTrue(cardState.isValid)
        XCTAssertFalse(delegate.validStateChangedCalled)
        XCTAssertNil(delegate.validStateChangedParameter)
    }
    
    func testOnBecomeFirstResponder_fieldBecomesFirstResponder() {
        cardState.fieldStates.forEach {
            cardState.onBecomeFirstResponder(field: $0.key)
            XCTAssertTrue(cardState.fieldStates[$0.key]!.isFirstResponder)
        }
    }
    
    func testOnBecomeFirstResponder_previousFirstResponderField_notFirstResponder() {
        cardState.cardNumber.isFirstResponder = true
        cardState.onBecomeFirstResponder(field: .expiration)
        
        XCTAssertFalse(cardState.cardNumber.isFirstResponder)
    }
    
    func testOnResignFirstResponder_focusedFieldWasEdited_wasFirstResponderSet() {
        cardState.fieldStates.forEach {
            $0.value.isFirstResponder = true
            $0.value.wasEdited = true
            cardState.onResignFirstResponder()
            XCTAssertTrue(cardState.fieldStates[$0.key]!.wasFirstResponder)
        }
    }
    
    func testOnResignFirstResponder_focusedFieldWasNotEdited_wasFirstResponderNotSet() {
        cardState.fieldStates.forEach {
            $0.value.isFirstResponder = true
            $0.value.wasEdited = false
            cardState.onResignFirstResponder()
            XCTAssertFalse(cardState.fieldStates[$0.key]!.wasFirstResponder)
        }
    }
    
    func testOnResignFirstResponder_focusedFieldWasFirstResponder_isFirstResponderCleared() {
        cardState.fieldStates.forEach {
            $0.value.isFirstResponder = true
            cardState.onResignFirstResponder()
            XCTAssertFalse(cardState.fieldStates[$0.key]!.isFirstResponder)
        }
    }
    
    func testReset_cardBrand_setToUnknown() {
        cardState._cardBrand = .visa
        cardState.reset()
        XCTAssertEqual(OPCardBrand.unknown, cardState._cardBrand)
    }
    
    func testReset_postalCodeTextValid_setToFalse() {
        cardState._postalCodeTextValid = true
        cardState.reset()
        XCTAssertFalse(cardState._postalCodeTextValid)
    }
    
    func testReset_isValidToggledFalse_delegateCalled() {
        cardState.fieldStates.forEach {
            $0.value.isValid = true
        }
        
        let delegate = MockValidStateChangedDelegate()
        cardState.delegate = delegate
        
        XCTAssertTrue(cardState.isValid)
        cardState.reset()
        
        XCTAssertFalse(cardState.isValid)
        XCTAssertTrue(delegate.validStateChangedCalled)
        XCTAssertNotNil(delegate.validStateChangedParameter)
        XCTAssertFalse(delegate.validStateChangedParameter!)
    }
    
    func testReset_isValidNotToggledFalse_delegateNotCalled() {
        let delegate = MockValidStateChangedDelegate()
        cardState.delegate = delegate
        
        XCTAssertFalse(cardState.isValid)
        cardState.reset()
        
        XCTAssertFalse(cardState.isValid)
        XCTAssertFalse(delegate.validStateChangedCalled)
        XCTAssertNil(delegate.validStateChangedParameter)
    }
    
    func testIsValidUSPostalCode_validPostalCode_returnsTrue() {
        XCTAssertTrue(cardState.isValidUsPostalCode("55056"))
    }
    
    func testIsValidUSPostalCode_postalCodeTooShort_returnsFalse() {
        XCTAssertFalse(cardState.isValidUsPostalCode("550"))
    }
    
    func testIsValidUSPostalCode_postalCodeTooLong_returnsFalse() {
        XCTAssertFalse(cardState.isValidUsPostalCode("1234567890"))
    }
    
    func testIsValidUSPostalCode_postalCodeNonDigits_returnsFalse() {
        XCTAssertFalse(cardState.isValidUsPostalCode("55A56"))
        XCTAssertFalse(cardState.isValidUsPostalCode("5.056"))
    }
    
    func testIsValidCAPostalCode_validPostalCode_returnsTrue() {
        XCTAssertTrue(cardState.isValidCaPostalCode("A1A 1A1"))
    }
    
    func testIsValidCaPostalCode_postalCodeContainsOnlyDigits_returnsFalse() {
        XCTAssertFalse(cardState.isValidCaPostalCode("111 121"))
    }
    
    func testIsValidPostalCode_containsValidPostalCode_returnsTrue() {
        XCTAssertTrue(cardState.isValidPostalCode("55056"))
        XCTAssertTrue(cardState.isValidPostalCode("A1A 1A1"))
    }
    
    func testIsValidPostalCode_containsInvalidPostalCode_returnsFalse() {
        XCTAssertFalse(cardState.isValidPostalCode("55.56"))
        XCTAssertFalse(cardState.isValidPostalCode("A1A41A1"))
    }
    
    func testIsInvalidField_ignoreUneditedFields_fieldInvalid_wasEdited_wasFirstResponder_returnsTrue() {
        cardState.fieldStates.forEach {
            XCTAssertFalse(cardState.isInvalidField($0.key, true))
            
            $0.value.isValid = false
            $0.value.wasEdited = true
            $0.value.wasFirstResponder = true
            XCTAssertTrue(cardState.isInvalidField($0.key, true))
        }
    }
    
    func testIsInvalidField_ignoreUneditedFields_fieldInvalid_wasEdited_notWasFirstResponder_returnsFalse() {
        cardState.fieldStates.forEach {
            XCTAssertFalse(cardState.isInvalidField($0.key, true))
            
            $0.value.isValid = false
            $0.value.wasEdited = true
            $0.value.wasFirstResponder = false
            XCTAssertFalse(cardState.isInvalidField($0.key, true))
        }
    }
    
    func testIsInvalidField_ignoreUneditedFields_fieldInvalid_notWasEdited_wasFirstResponder_returnsFalse() {
        cardState.fieldStates.forEach {
            XCTAssertFalse(cardState.isInvalidField($0.key, true))
            
            $0.value.isValid = false
            $0.value.wasEdited = false
            $0.value.wasFirstResponder = true
            XCTAssertFalse(cardState.isInvalidField($0.key, true))
        }
    }
    
    func testIsInvalidField_ignoreUneditedFields_fieldInvalid_notWasEdited_notWasFirstResponder_returnsFalse() {
        cardState.fieldStates.forEach {
            XCTAssertFalse(cardState.isInvalidField($0.key, true))
            
            $0.value.isValid = false
            $0.value.wasEdited = false
            $0.value.wasFirstResponder = false
            XCTAssertFalse(cardState.isInvalidField($0.key, true))
        }
    }
    
    func testIsInvalidField_ignoreUneditedFields_fieldValid_wasEdited_wasFirstResponder_returnsFalse() {
        cardState.fieldStates.forEach {
            XCTAssertFalse(cardState.isInvalidField($0.key, true))
            
            $0.value.isValid = true
            $0.value.wasEdited = true
            $0.value.wasFirstResponder = true
            XCTAssertFalse(cardState.isInvalidField($0.key, true))
        }
    }
    
    func testIsInvalidField_ignoreUneditedFields_fieldValid_wasEdited_notWasFirstResponder_returnsFalse() {
        cardState.fieldStates.forEach {
            XCTAssertFalse(cardState.isInvalidField($0.key, true))
            
            $0.value.isValid = true
            $0.value.wasEdited = true
            $0.value.wasFirstResponder = false
            XCTAssertFalse(cardState.isInvalidField($0.key, true))
        }
    }
    
    func testIsInvalidField_ignoreUneditedFields_fieldValid_notWasEdited_wasFirstResponder_returnsFalse() {
        cardState.fieldStates.forEach {
            XCTAssertFalse(cardState.isInvalidField($0.key, true))
            
            $0.value.isValid = true
            $0.value.wasEdited = false
            $0.value.wasFirstResponder = true
            XCTAssertFalse(cardState.isInvalidField($0.key, true))
        }
    }
    
    func testIsInvalidField_ignoreUneditedFields_fieldValid_notWasEdited_notWasFirstResponder_returnsFalse() {
        cardState.fieldStates.forEach {
            XCTAssertFalse(cardState.isInvalidField($0.key, true))
            
            $0.value.isValid = true
            $0.value.wasEdited = false
            $0.value.wasFirstResponder = false
            XCTAssertFalse(cardState.isInvalidField($0.key, true))
        }
    }
    
    func testIsInvalidField_notIgnoreUneditedFields_fieldInvalid_returnsTrue() {
        cardState.fieldStates.forEach {
            $0.value.isValid = false
            XCTAssertTrue(cardState.isInvalidField($0.key, false))
        }
    }
    
    func testIsInvalidField_notIgnoreUneditedFields_fieldInvalid_wasEdited_wasFirstResponder_returnsTrue() {
        cardState.fieldStates.forEach {
            XCTAssertTrue(cardState.isInvalidField($0.key, false))
            $0.value.isValid = false
            $0.value.wasEdited = true
            $0.value.wasFirstResponder = true
            XCTAssertTrue(cardState.isInvalidField($0.key, false))
        }
    }
    
    func testIsInvalidField_notIgnoreUneditedFields_fieldValid_returnsFalse() {
        cardState.fieldStates.forEach {
            XCTAssertTrue(cardState.isInvalidField($0.key, false))
            $0.value.isValid = true
            XCTAssertFalse(cardState.isInvalidField($0.key, false))
        }
    }
    
    func testIsInvalidField_notIgnoreUneditedFields_fieldValid_wasEdited_wasFirstResponder_returnsFalse() {
        cardState.fieldStates.forEach {
            XCTAssertTrue(cardState.isInvalidField($0.key, false))
            
            $0.value.isValid = true
            $0.value.wasEdited = true
            $0.value.wasFirstResponder = true
            XCTAssertFalse(cardState.isInvalidField($0.key, false))
        }
    }
    
    func testGetErrorFields_ignoreUneditedFields_hasErrorFields_returnsErrorFields() {
        cardState.cardNumber.isValid = false
        cardState.cardNumber.wasEdited = true
        cardState.cardNumber.wasFirstResponder = true
        
        cardState.expiration.isValid = false
        cardState.expiration.wasEdited = true
        cardState.expiration.wasFirstResponder = true
        
        let invalidFields = cardState.getErrorFields(ignoreUneditedFields: true)
        XCTAssertEqual(2, invalidFields.count)
        XCTAssertTrue(invalidFields.contains{ $0.key == .number })
        XCTAssertTrue(invalidFields.contains{ $0.key == .expiration })
    }
    
    func testGetErrorFields_ignoreUneditedFields_hasNoErrorFields_returnsNoFields() {
        cardState.cardNumber.isValid = true
        cardState.cardNumber.wasEdited = true
        cardState.cardNumber.wasFirstResponder = true
        
        cardState.expiration.isValid = false
        cardState.expiration.wasEdited = true
        cardState.expiration.wasFirstResponder = false
        
        cardState.cvv.isValid = false
        cardState.cvv.wasEdited = false
        cardState.cvv.wasFirstResponder = true
        
        cardState.postalCode.isValid = false
        cardState.postalCode.wasEdited = false
        cardState.postalCode.wasFirstResponder = false
        
        let invalidFields = cardState.getErrorFields(ignoreUneditedFields: true)
        
        XCTAssertEqual(0, invalidFields.count)
    }
    
    func testGetErrorFields_notIgnoreUneditedFields_hasErrorFields_returnsErrorFields() {
        cardState.cardNumber.wasEdited = true
        cardState.cardNumber.wasFirstResponder = true
        
        cardState.expiration.wasEdited = true
        cardState.expiration.wasFirstResponder = false
        
        cardState.cvv.wasEdited = false
        cardState.cvv.wasFirstResponder = true
        
        cardState.postalCode.wasEdited = false
        cardState.postalCode.wasFirstResponder = false
        
        let invalidFields = cardState.getErrorFields(ignoreUneditedFields: false)
        
        XCTAssertEqual(4, invalidFields.count)
        XCTAssertTrue(invalidFields.contains{ $0.key == .number })
        XCTAssertTrue(invalidFields.contains{ $0.key == .expiration })
        XCTAssertTrue(invalidFields.contains{ $0.key == .cvv })
        XCTAssertTrue(invalidFields.contains{ $0.key == .postalCode })
    }
    
    func testGetErrorFields_notIgnoreUneditedFields_hasNoErrorFields_returnsNoFields() {
        cardState.fieldStates.forEach {
            $0.value.isValid = true
        }
        
        cardState.cardNumber.wasEdited = true
        cardState.cardNumber.wasFirstResponder = true
        
        cardState.expiration.wasEdited = true
        cardState.expiration.wasFirstResponder = false
        
        cardState.cvv.wasEdited = false
        cardState.cvv.wasFirstResponder = true
        
        cardState.postalCode.wasEdited = false
        cardState.postalCode.wasFirstResponder = false
        
        let invalidFields = cardState.getErrorFields(ignoreUneditedFields: false)
        
        XCTAssertEqual(0, invalidFields.count)
    }
    
    private func customErrorMessageHandler(_ cardState: NSDictionary, _ cardBrand: OPCardBrand, _ ignoreUneditedFields: Bool) -> String {
        return "Custom Error"
    }
    
    fileprivate class MockValidStateChangedDelegate: NSObject, OPValidStateChangedDelegate {
        var validStateChangedCalled: Bool = false
        var validStateChangedParameter: Bool? = nil
        
        func validStateChanged(isValid: Bool) {
            validStateChangedCalled = true
            validStateChangedParameter = isValid
        }
    }
}
