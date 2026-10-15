// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  AutofillTraitsTests.swift
//  OloPaySDKTests
//

import XCTest
import UIKit
@testable import OloPaySDK

private final class CvvDelegateSpy: NSObject, OPPaymentCardCvvTextFieldDelegate {
    var fieldChangedCount = 0

    func fieldChanged(_ cvvTextField: OPPaymentCardCvvTextField) { fieldChangedCount += 1 }
    func didBeginEditing(_ cvvTextField: OPPaymentCardCvvTextField) {}
    func didEndEditing(_ cvvTextField: OPPaymentCardCvvTextField) {}
}

final class AutofillTraitsTests: XCTestCase {
    private let allFields: [OPCardField] = [.number, .expiration, .cvv, .postalCode, .unknown]

    private func assertSharedTraits(_ field: UITextField, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(field.autocorrectionType, .no, file: file, line: line)
        XCTAssertEqual(field.spellCheckingType, .no, file: file, line: line)
        XCTAssertEqual(field.smartDashesType, .no, file: file, line: line)
        XCTAssertEqual(field.smartQuotesType, .no, file: file, line: line)
        XCTAssertEqual(field.smartInsertDeleteType, .no, file: file, line: line)
    }

    private func assertNumber(_ field: UITextField?, file: StaticString = #filePath, line: UInt = #line) {
        guard let field = field else { return XCTFail("Number field not found", file: file, line: line) }
        XCTAssertEqual(field.textContentType, .creditCardNumber, file: file, line: line)
        assertSharedTraits(field, file: file, line: line)
    }

    private func assertExpiration(_ field: UITextField?, file: StaticString = #filePath, line: UInt = #line) {
        guard let field = field else { return XCTFail("Expiration field not found", file: file, line: line) }
        if #available(iOS 17.0, *) {
            XCTAssertEqual(field.textContentType, .creditCardExpiration, file: file, line: line)
        } else {
            XCTAssertNil(field.textContentType, file: file, line: line)
        }
        assertSharedTraits(field, file: file, line: line)
    }

    private func assertCvv(_ field: UITextField?, file: StaticString = #filePath, line: UInt = #line) {
        guard let field = field else { return XCTFail("CVV field not found", file: file, line: line) }
        if #available(iOS 17.0, *) {
            XCTAssertEqual(field.textContentType, .creditCardSecurityCode, file: file, line: line)
        } else {
            XCTAssertNil(field.textContentType, file: file, line: line)
        }
        assertSharedTraits(field, file: file, line: line)
    }

    private func assertPostal(_ field: UITextField?, file: StaticString = #filePath, line: UInt = #line) {
        guard let field = field else { return XCTFail("Postal field not found", file: file, line: line) }
        XCTAssertEqual(field.textContentType, .postalCode, file: file, line: line)
        XCTAssertEqual(field.autocapitalizationType, .allCharacters, file: file, line: line)
        assertSharedTraits(field, file: file, line: line)
    }

    private func assertAllFourFields(number: UITextField?, expiration: UITextField?, cvv: UITextField?, postal: UITextField?, file: StaticString = #filePath, line: UInt = #line) {
        assertNumber(number, file: file, line: line)
        assertExpiration(expiration, file: file, line: line)
        assertCvv(cvv, file: file, line: line)
        assertPostal(postal, file: file, line: line)
    }

    private func formFields(_ form: OPPaymentCardDetailsForm) -> (number: UITextField?, expiration: UITextField?, cvv: UITextField?, postal: UITextField?) {
        let fields = UIView.getAllTextFields(from: form)
        func find(_ typeName: String) -> UITextField? {
            fields.first { String(describing: type(of: $0)) == typeName }
        }
        return (find(OPStrings.stripeNumberField), find(OPStrings.stripeExiryField), find(OPStrings.stripeCvvField), find(OPStrings.stripePostalCodeField))
    }

    private func makeCvvField(text: String = "") -> (OPPaymentCardCvvTextField, CvvDelegateSpy) {
        let field = OPPaymentCardCvvTextField()
        let spy = CvvDelegateSpy()
        field.cvvDelegate = spy
        field.text = text
        return (field, spy)
    }

    func testApplyAutofillTraits_forNumber_setsCreditCardNumber() {
        let field = UITextField()
        field.applyAutofillTraits(for: .number)
        assertNumber(field)
    }

    func testApplyAutofillTraits_forPostalCode_setsPostalCodeAndAllCharacters() {
        let field = UITextField()
        field.applyAutofillTraits(for: .postalCode)
        assertPostal(field)
    }

    func testApplyAutofillTraits_forExpiration_setsExpirationContentType() {
        let field = UITextField()
        field.applyAutofillTraits(for: .expiration)
        assertExpiration(field)
    }

    func testApplyAutofillTraits_forCvv_setsSecurityCodeContentType() {
        let field = UITextField()
        field.applyAutofillTraits(for: .cvv)
        assertCvv(field)
    }

    func testApplyAutofillTraits_forUnknown_leavesContentTypeNil() {
        let field = UITextField()
        field.applyAutofillTraits(for: .unknown)
        XCTAssertNil(field.textContentType)
    }

    func testApplyAutofillTraits_forAnyField_setsSharedTraits() {
        allFields.forEach { cardField in
            let field = UITextField()
            field.applyAutofillTraits(for: cardField)
            assertSharedTraits(field)
        }
    }

    func testApplyAutofillTraits_forExpirationAndCvv_doesNotOverwriteExistingValueBeforeIOS17() throws {
        guard #unavailable(iOS 17.0) else { throw XCTSkip("Requires iOS < 17") }
        [OPCardField.expiration, .cvv].forEach { cardField in
            let field = UITextField()
            field.textContentType = .oneTimeCode
            field.applyAutofillTraits(for: cardField)
            XCTAssertEqual(field.textContentType, .oneTimeCode)
        }
    }

    func testInit_cvvTextField_appliesCvvTraitsAndKeepsNumberPad() {
        let field = OPPaymentCardCvvTextField()
        assertCvv(field)
        XCTAssertEqual(field.keyboardType, .numberPad)
    }

    func testInit_cvvView_innerFieldHasCvvTraits() {
        let view = OPPaymentCardCvvView()
        let fields = UIView.getAllTextFields(from: view)
        XCTAssertEqual(fields.count, 1)
        assertCvv(fields.first)
    }

    func testShouldChange_cvvView_withAutofillPayload_updatesViewState() {
        let view = OPPaymentCardCvvView()
        guard let field = UIView.getAllTextFields(from: view).first as? OPPaymentCardCvvTextField else {
            return XCTFail("CVV field not found")
        }
        XCTAssertFalse(field.textField(field, shouldChangeCharactersIn: NSRange(location: 0, length: 0), replacementString: "123 "))
        XCTAssertEqual(field.text, "123")
        XCTAssertTrue(view.isValid)
        XCTAssertFalse(view.fieldState.isEmpty)
        XCTAssertNotNil(view.getCvvTokenParams())
    }

    func testShouldChange_emptyField_withSingleDigit_allowsAndLeavesTextAlone() {
        let (field, spy) = makeCvvField()
        XCTAssertTrue(field.textField(field, shouldChangeCharactersIn: NSRange(location: 0, length: 0), replacementString: "1"))
        XCTAssertEqual(field.text, "")
        XCTAssertEqual(spy.fieldChangedCount, 0)
    }

    func testShouldChange_withDeletion_allows() {
        let (field, spy) = makeCvvField(text: "12")
        XCTAssertTrue(field.textField(field, shouldChangeCharactersIn: NSRange(location: 1, length: 1), replacementString: ""))
        XCTAssertEqual(field.text, "12")
        XCTAssertEqual(spy.fieldChangedCount, 0)
    }

    func testShouldChange_emptyField_withLetter_rejects() {
        let (field, spy) = makeCvvField()
        XCTAssertFalse(field.textField(field, shouldChangeCharactersIn: NSRange(location: 0, length: 0), replacementString: "a"))
        XCTAssertEqual(field.text, "")
        XCTAssertEqual(spy.fieldChangedCount, 0)
    }

    func testShouldChange_emptyField_withLoneSpaceAndContentType_allowsHandshake() {
        let (field, spy) = makeCvvField()
        field.textContentType = .oneTimeCode
        XCTAssertTrue(field.textField(field, shouldChangeCharactersIn: NSRange(location: 0, length: 0), replacementString: " "))
        XCTAssertEqual(field.text, "")
        XCTAssertEqual(spy.fieldChangedCount, 0)
    }

    func testShouldChange_emptyField_withLoneSpaceAndNoContentType_rejects() {
        let (field, spy) = makeCvvField()
        field.textContentType = nil
        XCTAssertFalse(field.textField(field, shouldChangeCharactersIn: NSRange(location: 0, length: 0), replacementString: " "))
        XCTAssertEqual(field.text, "")
        XCTAssertEqual(spy.fieldChangedCount, 0)
    }

    func testShouldChange_emptyField_withPayloadTrailingSpace_sanitizes() {
        let (field, spy) = makeCvvField()
        XCTAssertFalse(field.textField(field, shouldChangeCharactersIn: NSRange(location: 0, length: 0), replacementString: "123 "))
        XCTAssertEqual(field.text, "123")
        XCTAssertEqual(spy.fieldChangedCount, 1)
    }

    func testShouldChange_afterHandshakeSpace_withPayloadAppended_sanitizes() {
        let (field, spy) = makeCvvField(text: " ")
        XCTAssertFalse(field.textField(field, shouldChangeCharactersIn: NSRange(location: 1, length: 0), replacementString: "123 "))
        XCTAssertEqual(field.text, "123")
        XCTAssertEqual(spy.fieldChangedCount, 1)
    }

    func testShouldChange_afterHandshakeSpace_withPayloadReplacingSpace_sanitizes() {
        let (field, spy) = makeCvvField(text: " ")
        XCTAssertFalse(field.textField(field, shouldChangeCharactersIn: NSRange(location: 0, length: 1), replacementString: "123 "))
        XCTAssertEqual(field.text, "123")
        XCTAssertEqual(spy.fieldChangedCount, 1)
    }

    func testShouldChange_afterHandshakeSpace_withSingleDigit_selfHeals() {
        let (field, spy) = makeCvvField(text: " ")
        XCTAssertFalse(field.textField(field, shouldChangeCharactersIn: NSRange(location: 1, length: 0), replacementString: "1"))
        XCTAssertEqual(field.text, "1")
        XCTAssertEqual(spy.fieldChangedCount, 1)
    }

    func testShouldChange_emptyField_withOverlongPayload_truncates() {
        let (field, spy) = makeCvvField()
        XCTAssertFalse(field.textField(field, shouldChangeCharactersIn: NSRange(location: 0, length: 0), replacementString: "12345"))
        XCTAssertEqual(field.text, "1234")
        XCTAssertEqual(spy.fieldChangedCount, 1)
    }

    func testShouldChange_fullField_withAppendedDigit_rejectsWithoutMutation() {
        let (field, spy) = makeCvvField(text: "1234")
        XCTAssertFalse(field.textField(field, shouldChangeCharactersIn: NSRange(location: 4, length: 0), replacementString: "5"))
        XCTAssertEqual(field.text, "1234")
        XCTAssertEqual(spy.fieldChangedCount, 0)
    }

    func testShouldChange_fullField_withMidStringInsert_rejectsWithoutMutation() {
        let (field, spy) = makeCvvField(text: "1234")
        XCTAssertFalse(field.textField(field, shouldChangeCharactersIn: NSRange(location: 2, length: 0), replacementString: "5"))
        XCTAssertEqual(field.text, "1234")
        XCTAssertEqual(spy.fieldChangedCount, 0)
    }

    func testShouldChange_fullField_withWholeTextPayloadReplacement_sanitizes() {
        let (field, spy) = makeCvvField(text: "1234")
        XCTAssertFalse(field.textField(field, shouldChangeCharactersIn: NSRange(location: 0, length: 4), replacementString: "5678 "))
        XCTAssertEqual(field.text, "5678")
        XCTAssertEqual(spy.fieldChangedCount, 1)
    }

    func testShouldChange_nonEmptyField_withNonDigit_rejectsWithoutMutation() {
        let (field, spy) = makeCvvField(text: "123")
        XCTAssertFalse(field.textField(field, shouldChangeCharactersIn: NSRange(location: 3, length: 0), replacementString: "a"))
        XCTAssertEqual(field.text, "123")
        XCTAssertEqual(spy.fieldChangedCount, 0)
    }
    
    func testShouldChange_fullField_withNonDigitInsert_rejectsWithoutMutation() {
        let (field, spy) = makeCvvField(text: "1234")
        XCTAssertFalse(field.textField(field, shouldChangeCharactersIn: NSRange(location: 2, length: 0), replacementString: "a"))
        XCTAssertEqual(field.text, "1234")
        XCTAssertEqual(spy.fieldChangedCount, 0)
    }
    
    func testShouldChange_fullField_withDigitReplacingSelection_allows() {
        let (field, spy) = makeCvvField(text: "1234")
        XCTAssertTrue(field.textField(field, shouldChangeCharactersIn: NSRange(location: 0, length: 1), replacementString: "5"))
        XCTAssertEqual(field.text, "1234")
        XCTAssertEqual(spy.fieldChangedCount, 0)
    }
    
    func testShouldChange_nonEmptyField_withAppendedDigit_allows() {
        let (field, spy) = makeCvvField(text: "12")
        XCTAssertTrue(field.textField(field, shouldChangeCharactersIn: NSRange(location: 2, length: 0), replacementString: "3"))
        XCTAssertEqual(field.text, "12")
        XCTAssertEqual(spy.fieldChangedCount, 0)
    }
    
    func testShouldChange_withOutOfRangeRange_rejectsWithoutException() {
        let (field, spy) = makeCvvField(text: "12")
        XCTAssertFalse(field.textField(field, shouldChangeCharactersIn: NSRange(location: 5, length: 0), replacementString: "3"))
        XCTAssertEqual(field.text, "12")
        XCTAssertEqual(spy.fieldChangedCount, 0)
    }

    func testShouldChange_emptyField_withMixedDigitsAndLetters_stripsNonDigits() {
        let (field, spy) = makeCvvField()
        XCTAssertFalse(field.textField(field, shouldChangeCharactersIn: NSRange(location: 0, length: 0), replacementString: "1a"))
        XCTAssertEqual(field.text, "1")
        XCTAssertEqual(spy.fieldChangedCount, 1)
    }

    func testShouldChange_emptyField_withNonAsciiDigits_rejects() {
        let (field, spy) = makeCvvField()
        XCTAssertFalse(field.textField(field, shouldChangeCharactersIn: NSRange(location: 0, length: 0), replacementString: "١٢٣"))
        XCTAssertEqual(field.text, "")
        XCTAssertEqual(spy.fieldChangedCount, 0)
    }

    func testInit_detailsView_appliesTraitsToAllFields() {
        let view = OPPaymentCardDetailsView()
        XCTAssertNotNil(view._numberField)
        XCTAssertNotNil(view._expirationField)
        XCTAssertNotNil(view._cvvField)
        XCTAssertNotNil(view._postalCodeField)
        assertAllFourFields(number: view._numberField, expiration: view._expirationField, cvv: view._cvvField, postal: view._postalCodeField)
    }

    func testCountryChange_detailsView_keepsTraitsAfterLayout() {
        let view = OPPaymentCardDetailsView()
        view.layoutIfNeeded()
        assertAllFourFields(number: view._numberField, expiration: view._expirationField, cvv: view._cvvField, postal: view._postalCodeField)

        ["CA", "US"].forEach { country in
            view._cardDetails.countryCode = country
            view.layoutIfNeeded()
            assertAllFourFields(number: view._numberField, expiration: view._expirationField, cvv: view._cvvField, postal: view._postalCodeField)
        }
    }

    func testInit_detailsForm_standard_appliesTraitsToAllFields() {
        let fields = formFields(OPPaymentCardDetailsForm())
        assertAllFourFields(number: fields.number, expiration: fields.expiration, cvv: fields.cvv, postal: fields.postal)
    }

    func testInit_detailsForm_borderless_appliesTraitsToAllFields() {
        let fields = formFields(OPPaymentCardDetailsForm(style: .borderless))
        assertAllFourFields(number: fields.number, expiration: fields.expiration, cvv: fields.cvv, postal: fields.postal)
    }

    func testLayout_detailsForm_keepsTraitsAfterLayout() {
        [OPCardFormStyle.standard, .borderless].forEach { style in
            let form = OPPaymentCardDetailsForm(style: style)
            form.layoutIfNeeded()
            let fields = formFields(form)
            assertAllFourFields(number: fields.number, expiration: fields.expiration, cvv: fields.cvv, postal: fields.postal)
        }
    }
}
