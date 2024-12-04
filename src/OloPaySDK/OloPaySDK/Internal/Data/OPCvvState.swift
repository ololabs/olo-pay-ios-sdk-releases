// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPCvvState.swift
//  OloPaySDK
//
//  Created by Justin Anderson on 8/21/23.
//

import Foundation

// Class to manage state for OPPaymentCardCvvView
class OPCvvState {
    let _fieldState = OPCardFieldState()
    
    static var errorMessageHandler: OPCvvErrorMessageBlock? = nil
    
    var delegate: OPValidStateChangedDelegate? = nil
    
    var isValid: Bool {
        get { return _fieldState.isValid }
    }
    
    var isFirstResponder: Bool {
        get { return _fieldState.isFirstResponder }
    }
    
    func editingCompleted() {
        _fieldState.wasEdited = true
        _fieldState.wasFirstResponder = true
    }
    
    func onInputChanged(_ newText: String) {
        _fieldState.isEmpty = newText.isEmpty
        
        if !newText.isEmpty {
            _fieldState.wasEdited = true
        }
        
        let previousValidState = isValid
        _fieldState.isValid = isValidCvv(cvv: newText)
        
        notifyValidStateChanged(previousValidState: previousValidState)
    }
    
    func onFirstResponderStateChanged(_ isFirstResponder: Bool) {
        let wasFirstResponder = _fieldState.isFirstResponder
        
        // Unless the field was edited, treat it as though the
        // field never entered the first responder state (this helps
        // prevent displaying an error prematurely)
        if wasFirstResponder && !isFirstResponder && _fieldState.wasEdited {
            _fieldState.wasFirstResponder = true
        }
        
        _fieldState.isFirstResponder = isFirstResponder
    }
    
    func reset() {
        let previousValidState = isValid
        _fieldState.reset()
        
        notifyValidStateChanged(previousValidState: previousValidState)
    }
    
    func hasErrorMessage(_ ignoreUneditedFieldErrors: Bool = true) -> Bool {
        if (!ignoreUneditedFieldErrors) {
            return !_fieldState.isValid
        }
        
        return !_fieldState.isValid && _fieldState.wasEdited && _fieldState.wasFirstResponder
    }
    
    func getErrorMessage(_ ignoreUneditedFieldErrors: Bool = true) -> String {
        guard hasErrorMessage(ignoreUneditedFieldErrors) else {
            return ""
        }
        
        guard let errorHandler = OPCvvState.errorMessageHandler else {
            // Return default error message
            return getCvvError()
        }
        
        // Return custom error messages
        return errorHandler(_fieldState, ignoreUneditedFieldErrors)
    }
    
    private func isValidCvv(cvv: String) -> Bool {
        let regEx = #"^[0-9]{3,4}$"#
        return cvv.range(of: regEx, options: .regularExpression) != nil
    }
    
    private func getCvvError() -> String {
        if (_fieldState.isValid) {
            return ""
        }
        
        if (_fieldState.isEmpty) {
            return OPStrings.emptyCvvError
        }
        
        return OPStrings.incompleteCvvError
    }
    
    private func notifyValidStateChanged(previousValidState: Bool) {
        if previousValidState != isValid {
            delegate?.validStateChanged(isValid: isValid)
        }
    }
}
