// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  CardInputViewModel.swift
//  OloPaySDKTestHarness
//
//  Created by Justin Anderson on 8/15/23.
//

import Foundation
import OloPaySDK

protocol CardInputViewModelDelegate: NSObjectProtocol {
    func isBusyChanged(busy: Bool)
    func settingsChanged(settings: TestHarnessSettingsProtocol)
}

class CardInputViewModel: NSObject, OPPaymentCardDetailsViewDelegate, OPPaymentCardDetailsFormDelegate, TestHarnessSettingsObserver {
    private let newSettingsHeader =    "--------------- NEW SETTINGS ---------------"
    
    private let _oloPayApi: OloPayAPIProtocol
    private let _settings: TestHarnessSettings
    private var _apiClient: OloApiClient?
    
    public var delegate: CardInputViewModelDelegate? = nil
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
    
    public func createPaymentMethod(params: OPPaymentMethodParamsProtocol) {
        isBusy = true
        
        guard _settings.completeOloPayPayment else {
            createPaymentMethod(with: params)
            isBusy = false
            return
        }
        
        createBasket() { basket in
            guard let basket = basket else {
                self.isBusy = false
                return
            }
            
            self.createPaymentMethod(with: params, for: basket)
            self.isBusy = false
        }
    }
    
    public func log(_ message: String?, prependNewLine: Bool = true, appendNewLine: Bool = true) {
        logViewModel.log(message, prependNewLine: prependNewLine, appendNewLine: appendNewLine)
    }
    
    public func logError(error: Error?) {
        logViewModel.logError(error: error)
    }
    
    func settingsChanged(settings: TestHarnessSettingsProtocol) {
        logSettings()
        _apiClient = OloApiClient.createFromSettings()
        delegate?.settingsChanged(settings: settings)
    }
    
    // Error message handler used to display custom error messages when the custom error messages setting is turned on
    @objc public func customErrorMessagehandler(_ cardState: NSDictionary, _ cardBrand: OPCardBrand, _ ignoreUneditedFieldErrors: Bool) -> String {
        var errorMessage: String? = nil
        
        let state = cardState as! Dictionary<OPCardField, OPCardFieldStateProtocol>
        
        let numberState = state[.number]!
        let ignoreNumber = ignoreUneditedFieldErrors && (!numberState.wasEdited || !numberState.wasFirstResponder)
        
        let expirationState = state[.expiration]!
        let ignoreExpiration = ignoreUneditedFieldErrors && (!expirationState.wasEdited || !expirationState.wasFirstResponder)
        
        let cvvState = state[.cvv]!
        let ignoreCvv = ignoreUneditedFieldErrors && (!cvvState.wasEdited || !cvvState.wasFirstResponder)
        
        let postalCodeState = state[.postalCode]!
        let ignorePostalCode = ignoreUneditedFieldErrors && (!postalCodeState.wasEdited || !postalCodeState.wasFirstResponder)
        
        if !numberState.isValid && !ignoreNumber {
            if numberState.isEmpty {
                errorMessage = OPStrings.emptyCardNumberError
            } else if cardBrand == OPCardBrand.unsupported {
                errorMessage = OPStrings.unsupportedCardError
            } else {
                errorMessage = OPStrings.invalidCardNumberError
            }
        } else if !expirationState.isValid && !ignoreExpiration {
            errorMessage = expirationState.isEmpty ?
                OPStrings.emptyExpirationError :
                OPStrings.invalidExpirationError
        } else if !cvvState.isValid && !ignoreCvv {
            errorMessage = cvvState.isEmpty ?
                OPStrings.emptyCvvError :
                OPStrings.invalidCvvError
        } else if !postalCodeState.isValid && !ignorePostalCode {
            errorMessage = postalCodeState.isEmpty ?
                OPStrings.emptyPostalCodeError :
                OPStrings.invalidPostalCodeError
        }
        
        return errorMessage == nil ? "" : "Custom: \(errorMessage!)"
    }
    
    private func createPaymentMethod(with params: OPPaymentMethodParamsProtocol, for basket: Basket? = nil) {
        log("Creating payment method...", appendNewLine: false)
        
        _oloPayApi.createPaymentMethod(with: params) { paymentMethod, error in
            self.logViewModel.logPaymentMethod(paymentMethod: paymentMethod)
            self.logViewModel.logError(error: error)
            
            guard let basket = basket, let paymentMethod = paymentMethod else {
                self.isBusy = false
                return
            }
            
            self.submitBasket(basket: basket, paymentMethod: paymentMethod)
        }
    }
    
    private func createBasket(completion: @escaping (_: Basket?) -> Void) {
        guard let apiClient = _apiClient else {
            log("Unable to complete payment... apiClient is nil")
            completion(nil)
            return
        }
        
        log("Creating Basket For Card...", appendNewLine: false)
        
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
    
    private func submitBasket(basket: Basket, paymentMethod: OPPaymentMethodProtocol) {
        guard let apiClient = _apiClient else {
            log("Unable to complete payment... apiClient is nil")
            isBusy = false
            return
        }
    
        log("Submitting order...", appendNewLine: false)
        apiClient.submitBasketFromSettings(with: paymentMethod, basketId: basket.id) { order, error, message in
            self.log(message)
            self.logViewModel.logError(error: error)
            
            guard let order = order else {
                self.isBusy = false
                return
            }
            
            self.log("Order created: \(order.id)")
            self.isBusy = false
        }
    }
    
    private func logSettings() {
        log(self.newSettingsHeader, appendNewLine: false)
        
        let useSingleLinePayment = _settings.useSingleLinePayment
        log("Payment Type: \(useSingleLinePayment ? "Single-Line" : "Multi-Line")", appendNewLine: false)
        
        if (useSingleLinePayment) {
            log("Log card details: \(_settings.logCardInputChanges)", appendNewLine: false)
            log("Display card errors: \(_settings.displayCardErrors)", appendNewLine: false)
            log("Use custom card errors: \(_settings.customCardErrorMessages)", appendNewLine: false)
            log("Display postal code: \(_settings.displayPostalCode)", appendNewLine: false)
        } else {
            log("Log form valid changes: \(_settings.logFormValidChanges)", appendNewLine: false)
        }
        
        let useOrderingApi = _settings.completeOloPayPayment
        log("Create Basket & Complete Payment: \(useOrderingApi)", appendNewLine: false)
        
        if (useOrderingApi) {
            log("API URL: \(_settings.baseAPIUrl ?? "")", appendNewLine: false)
            log("Restaurant Id: \(String(describing: _settings.restaurantId))", appendNewLine: false)
            log("Product Id: \(String(describing: _settings.productId))", appendNewLine: false)
            log("Product Qty: \(String(describing: _settings.productQty))", appendNewLine: false)
            log("Email: \(String(describing: _settings.userEmail))", appendNewLine: false)
        }
        
        log("")
    }
    
    @objc func paymentCardDetailsViewDidChange(with fieldStates: NSDictionary, isValid: Bool) {
        guard _settings.logCardInputChanges else {
            return
        }
        
        log("CardDetails Changed: IsValid: \(isValid)")
    }
    
    @objc func paymentCardDetailsViewDidBeginEditing(with fieldStates: NSDictionary, isValid: Bool) {
        guard _settings.logCardInputChanges else {
            return
        }
        
        log("CardDetails Begin Editing: CardValid: \(isValid)")
    }

    @objc func paymentCardDetailsViewDidEndEditing(with fieldStates: NSDictionary, isValid: Bool) {
        guard _settings.logCardInputChanges else {
            return
        }
        
        log("CardDetails End Editing: CardValid: \(isValid)")
    }

    @objc func paymentCardDetailsViewFieldDidBeginEditing(with fieldStates: NSDictionary, field: OPCardField, isValid: Bool) {
        guard _settings.logCardInputChanges else {
            return
        }
        
        log("Begin Editing: \(String(describing: field)) - CardValid: \(isValid)")
    }

    @objc func paymentCardDetailsViewFieldDidEndEditing(with fieldStates: NSDictionary, field: OPCardField, isValid: Bool) {
        guard _settings.logCardInputChanges else {
            return
        }
        
        log("End Editing: \(String(describing: field)) - CardValid: \(isValid)")
    }
    
    @objc func isValidChanged(_ isValid: Bool) {
        guard _settings.logFormValidChanges else {
            return
        }

        log("Form Is Valid: \(isValid)")
    }
}
