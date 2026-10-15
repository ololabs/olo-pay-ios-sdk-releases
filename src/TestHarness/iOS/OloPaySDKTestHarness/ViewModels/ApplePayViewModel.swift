// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  ApplePayViewModel.swift
//  OloPaySDKTestHarness
//
//  Created by Justin Anderson on 8/15/23.
//

import Foundation
import OloPaySDK
import PassKit

protocol ApplePayViewModelDelegate: NSObjectProtocol {
    func isBusyChanged(busy: Bool)
    func displayLineItemsChanged()
    func lineItemsValueChanged()
}

class ApplePayViewModel: NSObject, OPApplePayLauncherDelegate, TestHarnessSettingsObserver {
    private let newSettingsHeader =    "--------------- NEW SETTINGS ---------------"
    
    private let _oloPayApi: OloPayAPIProtocol
    private let _settings: TestHarnessSettings
    private var _apiClient: OloApiClient?
    
    private var _applePayFlowCompleted = false
    private var _applePayLauncher: OPApplePayLauncherProtocol
    private let _applePayCondition = NSCondition()
    
    private let _formatter = NumberFormatter()

    var displayLineItems: Bool {
        get { _settings.displayLineItems && !_settings.completeOloPayPayment }
    }
    
    var tax: NSDecimalNumber {
        get { NSDecimalNumber(string: _formatter.string(from: grandTotal.multiplying(by: 0.10))) }
    }
    
    var tip: NSDecimalNumber {
        get { NSDecimalNumber(string: _formatter.string(from: grandTotal.multiplying(by: 0.15))) }
    }
    
    var subtotal: NSDecimalNumber {
        get { grandTotal.subtracting(tax.adding(tip))}
    }

    private static var _defaultTotal: NSDecimalNumber = 12.12
    var grandTotal: NSDecimalNumber = _defaultTotal {
        didSet {
            delegate?.lineItemsValueChanged()
        }
    }
    
    public var delegate: ApplePayViewModelDelegate? = nil
    private(set) var logViewModel: LogViewModel
    
    private(set) var isBusy: Bool {
        didSet {
            delegate?.isBusyChanged(busy: self.isBusy)
        }
    }
    
    public var allSettings: TestHarnessSettingsProtocol {
        get { _settings.allSettings }
    }
    
    required init(logViewModel: LogViewModel, settings:TestHarnessSettings, oloPayApi: OloPayAPIProtocol) {
        _formatter.numberStyle = .decimal
        _formatter.minimumFractionDigits = 2
        _formatter.maximumFractionDigits = 2

        _oloPayApi = oloPayApi
        _settings = settings
        _apiClient = OloApiClient.createFromSettings()
        self.logViewModel = logViewModel
        isBusy = false
        
        let applePayConfig = OPApplePayConfiguration(
            merchantId: TestHarnessSettings.sharedInstance.merchantId ?? "",
            companyLabel: TestHarnessSettings.sharedInstance.companyLabel ?? "",
            currencyCode: .usd,
            countryCode: "US"
        )
        
        // This could be mocked for testing purposes
        _applePayLauncher = OPApplePayLauncher(configuration: applePayConfig)
        
        super.init()
        
        _applePayLauncher.delegate = self
        settings.addObserver(self)
    }
    
    func createPaymentMethod() {
        // If you want to be able to mock this call, you could instead do this:
        // type(of: _applePayLauncher).canMakePayments()
        guard OPApplePayLauncher.canMakePayments() else {
            log("Apple Pay not supported")
            return
        }
        
        isBusy = true
        guard _settings.completeOloPayPayment else {
            // Just create a payment method via Apple Pay and be done
            beginApplePayFlow()
            return
        }
        
        // Create a basket via the Olo Ordering API. Then create a payment method
        // via Apple Pay, and submit the basket to the ordering API with the
        // payment method
        createBasket() { basket in
            guard let basket = basket else {
                self.isBusy = false
                return
            }
            
            self.beginApplePayFlow(for: basket)
        }
    }
    
    func settingsChanged(settings: TestHarnessSettingsProtocol) {
        logSettings()
        grandTotal = ApplePayViewModel._defaultTotal
        delegate?.displayLineItemsChanged()
        _apiClient = OloApiClient.createFromSettings()
    }
    
    private func beginApplePayFlow(for basket: Basket? = nil) {
        do
        {
            _applePayFlowCompleted = false
            if let basket = basket {
                if let basketTotal = basket.total {
                    grandTotal = NSDecimalNumber(decimal: basketTotal)
                }
                _applePayLauncher.basketId = basket.id
            }
            
            var lineItems: [PKPaymentSummaryItem]? = nil
            
            if _settings.displayLineItems {
                let subTotalItem = PKPaymentSummaryItem(label: "Subtotal", amount: subtotal)
                let taxItem = PKPaymentSummaryItem(label: "Tax", amount: tax)
                let tipItem = PKPaymentSummaryItem(label: "Tip", amount: tip)
                
                lineItems = Array(arrayLiteral: subTotalItem, taxItem, tipItem)
            }
            
            try _applePayLauncher.present(for: grandTotal, with: lineItems, validateLineItems: true) {
                self.log("Apple Pay Sheet Presented", appendNewLine: false)
            }
            
        } catch OPApplePayLauncherError.emptyMerchantId {
            log("Error: Empty merchant ID")
            isBusy = false
        } catch OPApplePayLauncherError.emptyCompanyLabel {
            log("Error: Empty Company Label")
            isBusy = false
        } catch OPApplePayLauncherError.lineItemTotalMismatchError {
            log("Error: Sum of lineItems must equal grand total")
            isBusy = false
        } catch {
            log("Unspecified error")
            isBusy = false
        }
    }
        
    private func createBasket(completion: @escaping (_: Basket?) -> Void) {
        guard let apiClient = _apiClient else {
            log("Unable to complete payment... apiClient is nil")
            completion(nil)
            return
        }
        
        log("Creating Basket...", appendNewLine: false)
        
        apiClient.createBasketWithProductFromSettings() { basket, error, message in
            guard let basket = basket else {
                self.logError(error: error)
                self.log(message)
                completion(nil)
                return
            }
            
            self.log("Basket Created: \(String(describing: basket))")
            completion(basket)
        }
    }
    
    private func createError(with message: String) -> NSError {
        let userInfo: [String : String] = [ NSLocalizedDescriptionKey : message ]
        return NSError(domain: "com.olo.olopaysdktestharness", code: 400, userInfo: userInfo)
    }
    
    private func logSettings() {
        log(self.newSettingsHeader, appendNewLine: false)
        
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
    
    @objc func paymentMethodCreated(from launcher: OPApplePayLauncherProtocol, with paymentMethod: OPPaymentMethodProtocol) -> NSError? {
        logPaymentMethod(paymentMethod: paymentMethod)
        
        guard _settings.completeOloPayPayment else {
            return nil
        }
        
        guard let apiClient = _apiClient else {
            log("Unable to submit order... api client is nil")
            return createError(with: "Unable to submit order... api client is nil") //We should never get this far if apiClient is nil...
        }
        
        guard let basketId = launcher.basketId else {
            log("Unable to submit order... basket id is nil")
            return createError(with: "Unable to submit order... basket id is nil") //Likewise this should never happen
        }
        
        log("Submitting ApplePay order...", appendNewLine: false)
        
        var createdOrder: Order? = nil
        var orderMessage: String? = nil
        var orderError: Error? = nil

        _applePayCondition.lock() // Lock this thread until submit basket completes
        apiClient.submitBasketFromSettings(with: paymentMethod, basketId: basketId) { order, error, message in
            createdOrder = order
            orderError = error
            orderMessage = message
            self._applePayCondition.signal() //Tell the waiting thread to wake and check the condition again
        }
        
        // Check the condition and wait until the condition is no longer true
        while _applePayFlowCompleted == false && createdOrder == nil && orderMessage == nil && orderError == nil {
            _applePayCondition.wait()
        }
        
        _applePayCondition.unlock() //Unlock this thread so it can continue processing
        
        
        guard !_applePayFlowCompleted else {
            // This would only be true if Apple Pay timed out
            return nil
        }
        
        guard let order = createdOrder else {
            guard !_applePayFlowCompleted else {
                // This would only be true if Apple Pay timed out
                return nil
            }
            
            logError(error: orderError)
            
            if let orderMessage = orderMessage {
                log(orderMessage)
            }
            
            //Return an error to trigger an Apple Pay Error Dismissal
            return createError(with: (orderMessage ?? orderError?.localizedDescription) ?? "Unexpected error")
        }
        
        guard !_applePayFlowCompleted else {
            // This would only be true if Apple Pay timed out
            return nil
        }
        
        log("Order created: \(order.id)")
        
        //Return nil to trigger an Apple Pay Success Dismissal
        return nil
    }
    
    @objc func applePayDismissed(from launcher: OPApplePayLauncherProtocol, with status: OPApplePayStatus, error: Error?) {
        _applePayFlowCompleted = true
        _applePayCondition.signal()

        log("ApplePay Flow Completed")
        log("Status: \(String(describing: status))\n", appendNewLine: true)
        logError(error: error)
        isBusy = false
    }
    
    public func log(_ message: String?, prependNewLine: Bool = true, appendNewLine: Bool = true) {
        logViewModel.log(message, prependNewLine: prependNewLine, appendNewLine: appendNewLine)
    }
    
    func logError(error: Error?) {
        logViewModel.logError(error: error)
    }
    
    func logPaymentMethod(paymentMethod: OloPaySDK.OPPaymentMethodProtocol?) {
        logViewModel.logPaymentMethod(paymentMethod: paymentMethod)
    }
}
