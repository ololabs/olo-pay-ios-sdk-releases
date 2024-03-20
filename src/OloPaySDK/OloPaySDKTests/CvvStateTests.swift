// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  CvvStateTests.swift
//  OloPaySDKTests
//
//  Created by Justin Anderson on 8/21/23.
//

import XCTest
@testable import OloPaySDK

final class CvvStateTests: XCTestCase {
    lazy var _cvvState: OPCvvState? = nil
    var cvvState: OPCvvState {
        get { _cvvState! }
    }
    
    override func setUpWithError() throws {
        _cvvState = OPCvvState()
    }

    override func tearDownWithError() throws {
        OPCvvState.errorMessageHandler = nil
    }

    func testConstructor_validateInitialState() {
        XCTAssertFalse(cvvState.isValid)
        XCTAssertFalse(cvvState._fieldState.isValid)
        XCTAssertTrue(cvvState._fieldState.isEmpty)
        XCTAssertFalse(cvvState._fieldState.wasEdited)
        XCTAssertFalse(cvvState._fieldState.isFirstResponder)
        XCTAssertFalse(cvvState._fieldState.wasFirstResponder)
    }
    
    func testOnInputChanged_withEmptyText_stateIsEmpty_stateNotEdited() {
        cvvState.onInputChanged("")
        
        XCTAssertTrue(cvvState._fieldState.isEmpty)
        XCTAssertFalse(cvvState._fieldState.wasEdited)
    }
    
    func testOnInputChangd_withNonEmptyText_stateIsNotEmpty_stateWasEdited() {
        cvvState.onInputChanged("2")
        
        XCTAssertFalse(cvvState._fieldState.isEmpty)
        XCTAssertTrue(cvvState._fieldState.wasEdited)
    }
    
    func testOnInputChanged_withTooFewDigits_stateNotValid() {
        cvvState.onInputChanged("23")
        XCTAssertFalse(cvvState.isValid)
    }
    
    func testOnInputChanged_withTooManyDigits_stateNotValid() {
        cvvState.onInputChanged("23456")
        XCTAssertFalse(cvvState.isValid)
    }
    
    func testOnInputChanged_withCharacters_stateNotValid() {
        cvvState.onInputChanged("2a3")
        XCTAssertFalse(cvvState.isValid)
    }
    
    func testOnInputChanged_withThreeDigits_stateValid() {
        cvvState.onInputChanged("123")
        XCTAssertTrue(cvvState.isValid)
    }
    
    func testOnInputChanged_withFourDigits_stateValid() {
        cvvState.onInputChanged("1234")
        XCTAssertTrue(cvvState.isValid)
    }
    
    func testOnInputChanged_isValidToggledTrue_delegateCalled() {
        let cvvDelegate = MockValidStateChangedDelegate()
        cvvState.delegate = cvvDelegate
        
        XCTAssertFalse(cvvState.isValid)
        cvvState.onInputChanged("123")
        
        XCTAssertTrue(cvvState.isValid)
        XCTAssertTrue(cvvDelegate.validStateChangedCalled)
        XCTAssertNotNil(cvvDelegate.validStateChangedParameter)
        XCTAssertTrue(cvvDelegate.validStateChangedParameter!)
    }
    
    func testOnInputChanged_isValidToggledFalse_delegateCalled() {
        let cvvDelegate = MockValidStateChangedDelegate()
        cvvState.onInputChanged("123")
        
        cvvState.delegate = cvvDelegate
        
        XCTAssertTrue(cvvState.isValid)
        cvvState.onInputChanged("12")
        
        XCTAssertFalse(cvvState.isValid)
        XCTAssertTrue(cvvDelegate.validStateChangedCalled)
        XCTAssertNotNil(cvvDelegate.validStateChangedParameter)
        XCTAssertFalse(cvvDelegate.validStateChangedParameter!)
    }
    
    func testOnInputChanged_isValidNotToggled_delegateNotCalled() {
        let cvvDelegate = MockValidStateChangedDelegate()
        cvvState.onInputChanged("123")
        
        cvvState.delegate = cvvDelegate
        
        XCTAssertTrue(cvvState.isValid)
        cvvState.onInputChanged("345")
        
        XCTAssertTrue(cvvState.isValid)
        XCTAssertFalse(cvvDelegate.validStateChangedCalled)
        XCTAssertNil(cvvDelegate.validStateChangedParameter)
    }
    
    func testReset_isValidToggledFalse_delegateCalled() {
        let cvvDelegate = MockValidStateChangedDelegate()
        cvvState.onInputChanged("123")
        
        cvvState.delegate = cvvDelegate
        
        XCTAssertTrue(cvvState.isValid)
        cvvState.reset()
        
        XCTAssertFalse(cvvState.isValid)
        XCTAssertTrue(cvvDelegate.validStateChangedCalled)
        XCTAssertNotNil(cvvDelegate.validStateChangedParameter)
        XCTAssertFalse(cvvDelegate.validStateChangedParameter!)
    }
    
    func testReset_isValidNotToggled_delegateNotCalled() {
        let cvvDelegate = MockValidStateChangedDelegate()
        cvvState.onInputChanged("12")
        
        cvvState.delegate = cvvDelegate
        
        XCTAssertFalse(cvvState.isValid)
        cvvState.reset()
        
        XCTAssertFalse(cvvState.isValid)
        XCTAssertFalse(cvvDelegate.validStateChangedCalled)
        XCTAssertNil(cvvDelegate.validStateChangedParameter)
    }
    
    func testOnFirstResponderStateChanged_gainsFirstResponderState_stateIsFirstResponder_notStateWasFirstResponder() {
        cvvState.onFirstResponderStateChanged(true)
        XCTAssertTrue(cvvState._fieldState.isFirstResponder)
        XCTAssertFalse(cvvState._fieldState.wasFirstResponder)
    }

    func testOnFirstResponderStateChanged_leavesFirstResponderState_stateWasEdited_notStateIsFirstResponder_stateWasFirstResponder() {
        cvvState.onFirstResponderStateChanged(true)
        cvvState._fieldState.wasEdited = true
        cvvState.onFirstResponderStateChanged(false)
        XCTAssertFalse(cvvState._fieldState.isFirstResponder)
        XCTAssertTrue(cvvState._fieldState.wasFirstResponder)
    }
    
    func testOnFirstResponderStateChanged_leavesFirstResponderState_stateNotWasEdited_notStateIsFirstResponder_stateNotWasFirstResponder() {
        cvvState.onFirstResponderStateChanged(true)
        cvvState._fieldState.wasEdited = false
        cvvState.onFirstResponderStateChanged(false)
        XCTAssertFalse(cvvState._fieldState.isFirstResponder)
        XCTAssertFalse(cvvState._fieldState.wasFirstResponder)
    }
    
    func testHasErrorMessage_withoutIgnoreUneditedErrors_stateNotValid_returnsFalse() {
        cvvState._fieldState.isValid = true
        XCTAssertFalse(cvvState.hasErrorMessage(false))
    }
    
    func testHasErrorMessage_withoutIgnoreUneditedErrors_stateNotValid_returnsTrue() {
        cvvState._fieldState.isValid = false
        XCTAssertTrue(cvvState.hasErrorMessage(false))
    }
    
    func testHasErrorMessage_withIgnoreUneditedErrors_stateValid_stateEdited_stateWasResponder_returnsFalse() {
        cvvState._fieldState.isValid = true
        cvvState._fieldState.wasEdited = true
        cvvState._fieldState.wasFirstResponder = true
        XCTAssertFalse(cvvState.hasErrorMessage(true))
    }
    
    func testHasErrorMessage_withIgnoreUneditedErrors_stateValid_stateEdited_stateNotWasResponder_returnsFalse() {
        cvvState._fieldState.isValid = true
        cvvState._fieldState.wasEdited = true
        cvvState._fieldState.wasFirstResponder = false
        XCTAssertFalse(cvvState.hasErrorMessage(true))
    }
    
    func testHasErrorMessage_withIgnoreUneditedErrors_stateValid_stateNotEdited_stateWasResponder_returnsFalse() {
        cvvState._fieldState.isValid = true
        cvvState._fieldState.wasEdited = false
        cvvState._fieldState.wasFirstResponder = true
        XCTAssertFalse(cvvState.hasErrorMessage(true))
    }
    
    func testHasErrorMessage_withIgnoreUneditedErrors_stateValid_stateNotEdited_stateNotWasResponder_returnsFalse() {
        cvvState._fieldState.isValid = true
        cvvState._fieldState.wasEdited = false
        cvvState._fieldState.wasFirstResponder = false
        XCTAssertFalse(cvvState.hasErrorMessage(true))
    }
    
    func testHasErrorMessage_withIgnoreUneditedErrors_stateNotValid_stateEdited_stateWasResponder_returnsTrue() {
        cvvState._fieldState.isValid = false
        cvvState._fieldState.wasEdited = true
        cvvState._fieldState.wasFirstResponder = true
        XCTAssertTrue(cvvState.hasErrorMessage(true))
    }
    
    func testHasErrorMessage_withIgnoreUneditedErrors_stateNotValid_stateEdited_stateNotWasResponder_returnsFalse() {
        cvvState._fieldState.isValid = false
        cvvState._fieldState.wasEdited = true
        cvvState._fieldState.wasFirstResponder = false
        XCTAssertFalse(cvvState.hasErrorMessage(true))
    }
    
    
    func testHasErrorMessage_withIgnoreUneditedErrors_stateNotValid_stateNotEdited_stateWasResponder_returnsFalse() {
        cvvState._fieldState.isValid = false
        cvvState._fieldState.wasEdited = false
        cvvState._fieldState.wasFirstResponder = true
        XCTAssertFalse(cvvState.hasErrorMessage(true))
    }
    
    func testHasErrorMessage_withIgnoreUneditedErrors_stateNotValid_stateNotEdited_stateNotWasResponder_returnsFalse() {
        cvvState._fieldState.isValid = false
        cvvState._fieldState.wasEdited = false
        cvvState._fieldState.wasFirstResponder = false
        XCTAssertFalse(cvvState.hasErrorMessage(true))
    }
    
    func testGetErrorMessage_stateIsValid_returnsEmptyString() {
        cvvState._fieldState.isValid = true
        XCTAssertEqual("", cvvState.getErrorMessage())
    }
    
    func testGetErrorMessage_stateInvalid_stateEmpty_returnsEmptyCvvError() {
        cvvState._fieldState.isValid = false
        cvvState._fieldState.isEmpty = true
        XCTAssertEqual(OPStrings.emptyCvvError, cvvState.getErrorMessage(false))
    }
    
    func testGetErrorMessage_stateInvalid_stateNotEmpty_returnsIncompleteCvvError() {
        cvvState._fieldState.isValid = false
        cvvState._fieldState.isEmpty = false
        XCTAssertEqual(OPStrings.incompleteCvvError, cvvState.getErrorMessage(false))
    }
    
    func testGetErrorMessage_withCustomErrorHandler_stateInvalid_returnsCustomError() {
        OPCvvState.errorMessageHandler = customErrorMessageHandler(_:_:)
        cvvState._fieldState.isValid = false
        
        XCTAssertEqual("Custom Error", cvvState.getErrorMessage(false))
    }
    
    func testEditingCompleted() {
        cvvState.editingCompleted()
        XCTAssertTrue(cvvState._fieldState.wasEdited)
        XCTAssertTrue(cvvState._fieldState.wasFirstResponder)
    }
    
    private func customErrorMessageHandler(_ state: OPCardFieldStateProtocol, _ ignoreUneditedFieldErrors: Bool) -> String {
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
