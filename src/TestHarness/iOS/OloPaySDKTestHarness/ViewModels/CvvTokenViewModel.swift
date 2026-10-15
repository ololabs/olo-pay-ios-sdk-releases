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
    private var _apiClient: OloApiClient?
    
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
        _apiClient = OloApiClient.createFromSettings()
        self.logViewModel = logViewModel
        isBusy = false
        
        super.init()
        
        settings.addObserver(self)
    }
    
    func createToken(params: OPCvvTokenParamsProtocol) {
        isBusy = true
        
        guard _settings.completeOloPayPayment else {
            createToken(with: params)
            isBusy = false
            return
        }
        
        guard _settings.useLoggedInUser else {
            createToken(with: params)
            log("Warning: CVV token orders can only be completed with a logged in user. Creating CVV token without completing order.")
            isBusy = false
            return
        }
        
        createBasket() { basket in
            guard let basket = basket else {
                self.isBusy = false
                return
            }
            
            self.createToken(with: params, for: basket)
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
        _apiClient = OloApiClient.createFromSettings()
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
    
    private func createToken(with params: OPCvvTokenParamsProtocol, for basket: Basket? = nil) {
        log("Creating CVV Token...", appendNewLine: false)
        
        _oloPayApi.createCvvUpdateToken(with: params) { token, error in
            self.logViewModel.logCvvToken(token: token)
            self.logViewModel.logError(error: error)
            
            guard let basket = basket, let token = token else {
                self.isBusy = false
                return
            }
            
            self.submitBasket(basket: basket, token: token)
        }
    }
    
    private func createBasket(completion: @escaping (_: Basket?) -> Void) {
        guard let apiClient = _apiClient else {
            log("Unable to complete payment... apiClient is nil")
            completion(nil)
            return
        }
        
        log("Creating Basket For CVV Token...", appendNewLine: false)
        
        apiClient.createBasketWithProductFromSettings() { basket, error, message in
            guard let basket = basket else {
                self.logViewModel.logError(error: error)
                self.log(message)
                completion(nil)
                return
            }
            
            self.log("Basket Created: \(String(describing: basket))")
            completion(basket)
        }
    }
    
    private func submitBasket(basket: Basket, token: OPCvvUpdateTokenProtocol) {
        guard let apiClient = _apiClient else {
            log("Unable to complete payment... apiClient is nil")
            isBusy = false
            return
        }
    
        log("Submitting order...", appendNewLine: false)
        apiClient.submitBasketFromSettings(with: token, basketId: basket.id) { order, error, message in
            self.log(message)
            self.logViewModel.logError(error: error)
            
            guard let order = order else {
                self.isBusy = false
                self.log("Order not created")
                return
            }
            
            self.log("Order created: \(order.id)")
            self.isBusy = false
        }
    }
}
