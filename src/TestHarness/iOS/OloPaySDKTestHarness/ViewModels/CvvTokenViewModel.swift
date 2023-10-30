// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  CvvTokenViewModel.swift
//  OloPaySDKTestHarness
//
//  Created by Justin Anderson on 8/15/23.
//

import Foundation
import OloPaySDK

protocol CvvTokenViewModelDelegate: NSObjectProtocol {
    func isBusyChanged(busy: Bool)
    func settingsChanged(settings: TestHarnessSettingsProtocol)
}

class CvvTokenViewModel: NSObject, OPPaymentCardCvvViewDelegate, TestHarnessSettingsObserver {
    private let newSettingsHeader =    "--------------- NEW SETTINGS ---------------"
    
    private let _oloPayApi: OloPayAPIProtocol
    private let _settings: TestHarnessSettings
    
    public var delegate: CvvTokenViewModelDelegate? = nil
    private(set) var logViewModel: LogViewModel
    
    private(set) var isBusy: Bool {
        didSet {
            delegate?.isBusyChanged(busy: self.isBusy)
        }
    }
    
    public var allSettings: TestHarnessSettingsProtocol {
        get { _settings.allSettings }
    }
    
    required init(logViewModel: LogViewModel, settings: TestHarnessSettings, oloPayApi: OloPayAPIProtocol) {
        _oloPayApi = oloPayApi
        _settings = settings
        self.logViewModel = logViewModel
        isBusy = false
        
        super.init()
        
        settings.addObserver(self)
    }
    
    func createToken(params: OPCvvTokenParamsProtocol) {
        isBusy = true
        
        _oloPayApi.createCvvUpdateToken(with: params) { token, error in
            self.logViewModel.logCvvToken(token: token)
            self.logViewModel.logError(error: error)
            self.isBusy = false
        }
    }

    public func log(_ message: String?, prependNewLine: Bool = true, appendNewLine: Bool = true) {
        logViewModel.log(message, prependNewLine: prependNewLine, appendNewLine: appendNewLine)
    }
    
    @objc public func customErrorMessageHandler(_ fieldState: OPCardFieldStateProtocol, _ ignoreUneditedFieldErrors: Bool) -> String {
        if (fieldState.isValid) {
            return ""
        }
        
        if ignoreUneditedFieldErrors && (!fieldState.wasEdited || !fieldState.wasFirstResponder) {
            return ""
        }
        
        let errorMessage = fieldState.isEmpty ? OPStrings.emptyCvvError : OPStrings.incompleteCvvError
        
        return "Custom: \(errorMessage)"
    }
    
    func settingsChanged(settings: TestHarnessSettingsProtocol) {
        logSettings()
        delegate?.settingsChanged(settings: settings)
    }
    
    
    @objc func fieldChanged(with state: OPCardFieldStateProtocol) {
        guard _settings.logCvvInputChanges else {
            return
        }
        
        log("CVV Input Changed: \(String(describing: state))", appendNewLine: true)
    }
    
    
    @objc func didBeginEditing(with state: OPCardFieldStateProtocol) {
        guard _settings.logCvvInputChanges else {
            return
        }
        
        log("CVV Begin Editing: \(String(describing: state))", appendNewLine: true)
    }
    
    @objc func didEndEditing(with state: OPCardFieldStateProtocol) {
        guard _settings.logCvvInputChanges else {
            return
        }
        
        log("CVV End Editing: \(String(describing: state))", appendNewLine: true)
    }
    
    @objc func validStateChanged(with state: OPCardFieldStateProtocol) {
        guard _settings.logCvvInputChanges else {
            return
        }
        
        log("IsValid Changed: \(state.isValid)")
    }
    
    private func logSettings() {
        log(self.newSettingsHeader, appendNewLine: false)
        
        log("Log CVV Input Changes: \(_settings.logCvvInputChanges)", appendNewLine: false)
        log("Display CVV errors: \(_settings.displayCvvErrors)", appendNewLine: false)
        log("Use custom CVV errors: \(_settings.customCvvErrorMessages)", appendNewLine: true)
    }
}
