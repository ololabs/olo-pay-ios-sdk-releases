// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  ViewController.swift
//  OloPaySDKTestHarness
//
//  Created by Kyle Szklenski on 5/24/21.
//

import UIKit
import OloPaySDK
import PassKit

class ViewController: UIViewController, OPApplePayContextDelegate, OPPaymentCardDetailsViewDelegate, OPPaymentCardDetailsFormDelegate {
    let formSubmitHeader = "---------- FORM DETAILS SUBMISSION ----------"
    let cardSubmitHeader = "---------- CARD DETAILS SUBMISSION ----------"
    let applePaySubmitHeader = "----------- APPLE PAY SUBMISSION -----------"
    let newSettingsHeader =    "--------------- NEW SETTINGS ---------------"
    
    var _apiClient: OloApiClient?
    
    var _navigationBar = UINavigationBar()
    var _cardView = OPPaymentCardDetailsView()
    var _formView = OPPaymentCardDetailsForm()
    var _paymentStackView = UIStackView()
    var _logView = UITextView()
    
    var _submitButton = UIButton()
    var _applePayButton = UIButton()
    var _clearLogButton = UIButton()
    var _paymentView : UIView? = nil
    
    var _applePayContext: OPApplePayContextProtocol? = nil
    var _oloPayApi: OloPayAPIProtocol = OloPayAPI() //This could be mocked for testing purposes
    let _applePayCondition = NSCondition()
    var _applePayFlowCompleted = false
    
    @objc public required init?(coder: NSCoder) {
        _paymentView = _cardView
        _apiClient = OloApiClient.createFromSettings()
        super.init(coder: coder)
        resetLog()
    }

    var submissionInProgress: Bool = false {
        didSet {
            dispatchToMainThreadIfNecessary {
                self._submitButton.isUserInteractionEnabled = !self.submissionInProgress
                self._submitButton.isEnabled = !self.submissionInProgress
                self._applePayButton.isUserInteractionEnabled = !self.submissionInProgress
                self._applePayButton.isEnabled = !self.submissionInProgress
            }
        }
    }
    
    @objc func openSettings() {
        let settings = SettingsViewController()
        
        settings.onDismiss = {
            self.logSettings()
            self.updateSettings()
        }
        
        _cardView.resignFirstResponder()
        _formView.resignFirstResponder()
        self.present(settings, animated: true)
    }
    
    func logSettings() {
        self.log(self.newSettingsHeader, appendNewLine: false)
        
        let useSingleLinePayment = TestHarnessSettings.sharedInstance.useSingleLinePayment
        self.log("Payment Type: \(useSingleLinePayment ? "Single-Line" : "Multi-Line")", appendNewLine: false)
        
        if (useSingleLinePayment) {
            self.log("Log card details: \(TestHarnessSettings.sharedInstance.logCardInputChanges)", appendNewLine: false)
            self.log("Display card errors: \(TestHarnessSettings.sharedInstance.displayCardErrors)", appendNewLine: false)
            self.log("Use custom card errors: \(TestHarnessSettings.sharedInstance.customCardErrorMessages)", appendNewLine: false)
            self.log("Display postal code: \(TestHarnessSettings.sharedInstance.displayPostalCode)", appendNewLine: false)
        } else {
            self.log("Log form valid changes: \(TestHarnessSettings.sharedInstance.logFormValidChanges)", appendNewLine: false)
        }
        
        let useOrderingApi = TestHarnessSettings.sharedInstance.completeOloPayPayment ?? false
        self.log("Create Basket & Complete Payment: \(useOrderingApi)", appendNewLine: false)
        
        if (useOrderingApi) {
            self.log("API URL: \(TestHarnessSettings.sharedInstance.baseAPIUrl ?? "")", appendNewLine: false)
            self.log("Restaurant Id: \(String(describing: TestHarnessSettings.sharedInstance.restaurantId))", appendNewLine: false)
            self.log("Product Id: \(String(describing: TestHarnessSettings.sharedInstance.productId))", appendNewLine: false)
            self.log("Product Qty: \(String(describing: TestHarnessSettings.sharedInstance.productQty))", appendNewLine: false)
            self.log("Email: \(String(describing: TestHarnessSettings.sharedInstance.userEmail))", appendNewLine: false)
        }
        
        self.log("") //Create empty line
    }
    
    func updateSettings() {
        self._apiClient = OloApiClient.createFromSettings()
        
        _cardView.clear()
        _cardView.displayGeneratedErrorMessages = TestHarnessSettings.sharedInstance.displayCardErrors
        _cardView.postalCodeEntryEnabled = TestHarnessSettings.sharedInstance.displayPostalCode
        OPPaymentCardDetailsView.errorMessageHandler = TestHarnessSettings.sharedInstance.customCardErrorMessages ? getCustomErrorMessage : OPPaymentCardDetailsView.getErrorMessage
        
        updatePaymentStack()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view?.backgroundColor = .white
        
        setUITestingIdentifiers()
        
        //Set up navigation bar
        let navigationItem = UINavigationItem(title: "Olo Pay SDK")
        let settingsButton = UIBarButtonItem(title: "Settings", style: UIBarButtonItem.Style.plain, target: nil, action: #selector(self.openSettings))
        settingsButton.accessibilityIdentifier = UITestingIdentifiers.TestHarness.settingsButton
        navigationItem.rightBarButtonItem = settingsButton
        _navigationBar.items = [navigationItem]
        
        // Set up payment views
        _cardView.cardDetailsDelegate = self
        _formView.cardDetailsDelegate = self
        _paymentStackView.axis = NSLayoutConstraint.Axis.vertical
        _paymentStackView.distribution = UIStackView.Distribution.fill
        _paymentStackView.alignment = UIStackView.Alignment.fill
        
        // Set up log label
        let logLabel = UILabel()
        logLabel.text = "Output Log"
        
        // Set up log view
        _logView.textColor = .black
        _logView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.25)
        _logView.isEditable = false
        
        // Set up keyboard done button for input fields
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.dismissKeyboard))
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        toolbar.items = [doneButton]
        _cardView.inputAccessoryView = toolbar
        
        // Set up card submission button
        _submitButton.setTitle("Submit Card", for: .normal)
        _submitButton.backgroundColor = UIColor.black
        _submitButton.setTitleColor(UIColor.white, for: .normal)
        _submitButton.setTitleColor(UIColor.darkGray, for: .disabled)
        _submitButton.addTarget(self, action: #selector(submit), for: .touchUpInside)
        
        // Set up ApplePay submission button
        _applePayButton.setTitle("Apple Pay", for: .normal)
        _applePayButton.backgroundColor = UIColor.black
        _applePayButton.setTitleColor(UIColor.white, for: .normal)
        _applePayButton.setTitleColor(UIColor.darkGray, for: .disabled)
        _applePayButton.addTarget(self, action: #selector(submitApplePay), for: .touchUpInside)
        
        // Set up clear log button
        _clearLogButton.setTitle("Reset Log", for: .normal)
        _clearLogButton.backgroundColor = UIColor.black
        _clearLogButton.addTarget(self, action: #selector(resetLog), for: .touchUpInside)
        
        // Set up constraints
        let positiveViewSpacing: CGFloat = 10.0
        let negativeViewSpacing: CGFloat = -10.0
        
        updateSettings()
        let stackView = UIStackView(arrangedSubviews: [_navigationBar, _paymentStackView, logLabel, _logView, _submitButton, _applePayButton, _clearLogButton])
        stackView.axis = NSLayoutConstraint.Axis.vertical
        stackView.distribution = UIStackView.Distribution.fill
        stackView.alignment = UIStackView.Alignment.fill
        stackView.spacing = positiveViewSpacing
        
        let window = UIApplication.shared.windows[0]
        let topMargin = window.safeAreaInsets.top
        let bottomMargin = -1 * (window.safeAreaInsets.bottom + 10)

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: topMargin),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: bottomMargin),
            
            _paymentStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: positiveViewSpacing),
            _paymentStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: negativeViewSpacing),
            
            logLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: positiveViewSpacing),
            logLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: negativeViewSpacing),
            
            _logView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: positiveViewSpacing),
            _logView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: negativeViewSpacing),
            _logView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
            
            _submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: positiveViewSpacing),
            _submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: negativeViewSpacing),
            
            _applePayButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: positiveViewSpacing),
            _applePayButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: negativeViewSpacing),
            
            _clearLogButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: positiveViewSpacing),
            _clearLogButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: negativeViewSpacing)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func setUITestingIdentifiers() {
        _navigationBar.accessibilityIdentifier = UITestingIdentifiers.TestHarness.navigationBar
        _cardView.accessibilityIdentifier = UITestingIdentifiers.TestHarness.cardView
        _formView.accessibilityIdentifier = UITestingIdentifiers.TestHarness.formView
        _logView.accessibilityIdentifier = UITestingIdentifiers.TestHarness.logView
        _submitButton.accessibilityIdentifier = UITestingIdentifiers.TestHarness.submitButton
        _applePayButton.accessibilityIdentifier = UITestingIdentifiers.TestHarness.applePayButton
        _clearLogButton.accessibilityIdentifier = UITestingIdentifiers.TestHarness.clearLogButton
    }
    
    func updatePaymentStack() {
        guard let paymentView = _paymentView else {
            return
        }
        paymentView.removeFromSuperview()
        
        if TestHarnessSettings.sharedInstance.useSingleLinePayment {
            _paymentView = _cardView
        } else {
            _paymentView = _formView
        }
        
        _paymentStackView.addArrangedSubview(_paymentView!)
    }
    
    @objc func dismissKeyboard() {
        _cardView.resignFirstResponder()
    }
    
    @objc func submitApplePay() {
        self.log(applePaySubmitHeader, prependNewLine: false, appendNewLine: false)
        
        guard _oloPayApi.deviceSupportsApplePay() else {
            self.log("Apple Pay not supported")
            return
        }
        
        guard let complete = TestHarnessSettings.sharedInstance.completeOloPayPayment, complete == true else {
            BeginApplePayFlow()
            return
        }
        
        completeApplePayPayment()
    }
    
    func BeginApplePayFlow(for basket: Basket? = nil) {
        do
        {
            _applePayFlowCompleted = false
            var total: NSDecimalNumber = 0.12
            var basketId: String? = nil
            if let basket = basket {
                if let basketTotal = basket.total {
                    total = NSDecimalNumber(decimal: basketTotal)
                }
                basketId = basket.id
            }
            
            let pkPaymentRequest = try _oloPayApi.createPaymentRequest(forAmount: total, inCountry: "US", withCurrency: "USD")
            
            // This can be mocked for testing purposes
            _applePayContext = OPApplePayContext(paymentRequest: pkPaymentRequest, delegate: self, basketId: basketId)
            
            _applePayContext?.presentApplePay() {
                self.log("Apple Pay Sheet Presented", appendNewLine: false)
                self.log("Payment Request:\n\(String(describing: pkPaymentRequest))")
            }
        } catch OPApplePayContextError.missingMerchantId {
            self.log("Error: Missing merchant ID")
        } catch OPApplePayContextError.missingCompanyLabel {
            self.log("Error: Missing Company Label")
        } catch {
            self.log("Unspecified error")
        }
    }
    
    func completeApplePayPayment() {
        guard let apiClient = _apiClient else {
            self.log("Unable to complete Apple Pay payment... apiClient is nil")
            return
        }
        
        self.log("Creating Basket For Apple Pay...", appendNewLine: false)
        
        apiClient.createBasketWithProductFromSettings() { basket, error, errorMessage  in
            self.logError(error: error)
            self.log(errorMessage)
            
            guard let basket = basket else {
                self.log("Basket not created")
                return
            }
            
            self.log("Basket Created: \(String(describing: basket))")
            self.BeginApplePayFlow(for: basket)
        }
    }
    
    func createError(with message: String) -> NSError {
        let userInfo: [String : String] = [ NSLocalizedDescriptionKey : message ]
        return NSError(domain: "com.olo.olopaysdktestharness", code: 400, userInfo: userInfo)
    }

    @objc func applePaymentMethodCreated(_ context: OPApplePayContextProtocol, didCreatePaymentMethod paymentMethod: OPPaymentMethodProtocol) -> NSError? {
        logPaymentMethod(paymentMethod: paymentMethod)
        
        guard let complete = TestHarnessSettings.sharedInstance.completeOloPayPayment, complete == true else {
            return nil
        }
        
        guard let apiClient = _apiClient else {
            self.log("Unable to submit order... api client is nil")
            return createError(with: "Unable to submit order... api client is nil") //We should never get this far if apiClient is nil...
        }
        
        guard let basketId = context.basketId else {
            self.log("Unable to submit order... basket id is nil")
            return createError(with: "Unable to submit order... basket id is nil") //Likewise this should never happen
        }
        
        self.log("Submitting ApplePay order...", appendNewLine: false)
        
        var createdOrder: Order? = nil
        var orderMessage: String? = nil
        var orderError: Error? = nil

        _applePayCondition.lock() // Lock this thread until submit basket completes
        apiClient.submitBasketFromSettings(with: paymentMethod, basketId: basketId, billingSchemeId: TestHarnessSettings.sharedInstance.applePayBillingSchemeId) { order, error, message in
            createdOrder = order
            orderError = error
            orderMessage = message
            self._applePayCondition.signal() //Tell the waiting thread to wake and check the condition again
        }
        
        // Check the condition and wait until the condition is no longer true
        while _applePayFlowCompleted == false && createdOrder == nil && orderMessage == nil && orderMessage == nil {
            _applePayCondition.wait()
        }
        
        _applePayCondition.unlock() //Unlock this thread so it can continue processing
        
        guard let order = createdOrder else {
            self.logError(error: orderError)
            
            if let orderMessage = orderMessage {
                self.log(orderMessage)
            }
            
            return createError(with: (orderMessage ?? orderError?.localizedDescription) ?? "Unexpected error") //Return an error to trigger an Apple Pay Error Dismissal
        }
        
        self.log("Order created: \(order.id)")
        return nil //Return nil to trigger an Apple Pay Success Dismissal
    }
    
    @objc func applePaymentCompleted(_ context: OPApplePayContextProtocol, didCompleteWith status: OPPaymentStatus, error: Error?) {
        _applePayFlowCompleted = true
        _applePayCondition.signal()

        self.log("ApplePay Flow Completed")
        self.log("Status: \(String(describing: status))")
        logError(error: error)
        
        // Used in the wait condition for _applePayCondition in applePaymentMethodCreated(). If the wait condition takes too long, iOS will dismiss the
        // ApplePay payment sheet, which will cause this method to get executed... This ensures we don't wait indefinitely in applePaymentMethodCreated()
    }
    
    @objc func submit() {
        if TestHarnessSettings.sharedInstance.useSingleLinePayment {
            submitCard()
        } else {
            submitForm()
        }
    }
    
    @objc func submitCard() {
        submissionInProgress = true
        self.log(cardSubmitHeader, prependNewLine: false, appendNewLine: false)
        self.log("Card Is Valid: \(_cardView.isValid)")
        
        guard let complete = TestHarnessSettings.sharedInstance.completeOloPayPayment, complete == true else {
            createPaymentMethodWithCardView()
            submissionInProgress = false
            return
        }
        
        completePayment() { basket in
            guard let basket = basket else {
                self.submissionInProgress = false
                return
            }
            
            self.createPaymentMethodWithCardView(for: basket)
            self.submissionInProgress = false
        }
    }
    
    @objc func submitForm() {
        submissionInProgress = true
        self.log(formSubmitHeader, prependNewLine: false, appendNewLine: false)
        self.log("Form Is Valid: \(_formView.isValid)")
        
        guard let complete = TestHarnessSettings.sharedInstance.completeOloPayPayment, complete == true else {
            createPaymentMethodWithFormView()
            self.submissionInProgress = false
            return
        }
        
        completePayment() { basket in
            guard let basket = basket else {
                self.submissionInProgress = false
                return
            }
            
            self.createPaymentMethodWithFormView(for: basket)
            self.submissionInProgress = false
        }
    }
    
    func createPaymentMethodWithFormView(for basket: Basket? = nil) {
        guard let paymentParams = _formView.getPaymentMethodParams() else {
            self.log("Payment Params not valid, returning...", appendNewLine: false)
            return
        }
        self.log("Creating payment method...", appendNewLine: false)
        
        _oloPayApi.createPaymentMethod(with: paymentParams) { paymentMethod, error in
            self.submitBasket(basket: basket, paymentMethod: paymentMethod, error: error)
        }
    }
    
    func createPaymentMethodWithCardView(for basket: Basket? = nil) {
        do
        {
            let paymentParams = try _cardView.getPaymentMethodParams()
            self.log("Creating payment method...", appendNewLine: false)
            
            _oloPayApi.createPaymentMethod(with: paymentParams) { paymentMethod, error in
                self.submitBasket(basket: basket, paymentMethod: paymentMethod, error: error)
            }
        } catch {
            self.logError(error: error)
        }
    }
    
    func submitBasket(basket: Basket? = nil, paymentMethod: OPPaymentMethodProtocol?, error: Error?) {
        self.logError(error: error)
        self.logPaymentMethod(paymentMethod: paymentMethod)
        
        guard let basket = basket, let paymentMethod = paymentMethod, let apiClient = self._apiClient else {
            submissionInProgress = false
            return
        }
    
        self.log("Submitting order...", appendNewLine: false)
        apiClient.submitBasketFromSettings(with: paymentMethod, basketId: basket.id, billingSchemeId: paymentMethod.isApplePay ? TestHarnessSettings.sharedInstance.applePayBillingSchemeId : nil) { order, error, message in
            self.log(message)
            self.logError(error: error)
            
            guard let order = order else {
                self.submissionInProgress = false
                return
            }
            
            self.log("Order created: \(order.id)")
            self.submissionInProgress = false
        }
    }
    
    func completePayment(completion: @escaping (_: Basket?) -> Void) {
        guard let apiClient = _apiClient else {
            self.log("Unable to complete payment... apiClient is nil")
            completion(nil)
            return
        }
        
        self.log("Creating Basket For Card...", appendNewLine: false)
        
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
    
    func logPaymentMethod(paymentMethod: OPPaymentMethodProtocol?) {
        guard let unwrappedPaymentMethod = paymentMethod else {
            self.log("Payment method not created")
            return
        }
        
        self.log(String(describing: unwrappedPaymentMethod))
    }
    
    func logError(error: Error?) {
        guard let unwrappedError = error else {
            return
        }
        
        self.log(String(describing: unwrappedError as NSError))
        
        if let opError = unwrappedError as? OPError {
            self.log("OP Error Details:", appendNewLine: false)
            self.log("Error Type: \(opError.errorType)", appendNewLine: false)
            
            if let errorType = opError.cardErrorType {
                self.log("Card Error Type: \(errorType)", appendNewLine: false)
            } else {
                self.log("Card Error Type: nil", appendNewLine: false)
            }
            
            self.log("Card Error Message: \(opError.cardErrorMessage ?? "nil")")
        }
    }
    
    @objc func paymentCardDetailsViewDidChange(_ cardDetails: OPPaymentCardDetailsView) {
        guard TestHarnessSettings.sharedInstance.logCardInputChanges else {
            return
        }
        
        self.log("CardDetails Changed: IsValid: \(_cardView.isValid)", appendNewLine: false)
    }
    
    @objc func paymentCardDetailsViewDidBeginEditing(_ cardDetails: OPPaymentCardDetailsView) {
        guard TestHarnessSettings.sharedInstance.logCardInputChanges else {
            return
        }
        
        self.log("CardDetails Begin Editing: CardValid: \(_cardView.isValid)", appendNewLine: false)
    }

    @objc func paymentCardDetailsViewDidEndEditing(_ cardDetails: OPPaymentCardDetailsView) {
        guard TestHarnessSettings.sharedInstance.logCardInputChanges else {
            return
        }
        
        self.log("CardDetails End Editing: CardValid: \(_cardView.isValid)", appendNewLine: false)
    }

    @objc func paymentCardDetailsViewFieldDidBeginEditing(_ cardDetails: OPPaymentCardDetailsView, field: OPCardField) {
        guard TestHarnessSettings.sharedInstance.logCardInputChanges else {
            return
        }
        
        self.log("Begin Editing: \(String(describing: field)) - CardValid: \(_cardView.isValid)", appendNewLine: false)
    }

    @objc func paymentCardDetailsViewFieldDidEndEditing(_ cardDetails: OPPaymentCardDetailsView, field: OPCardField) {
        guard TestHarnessSettings.sharedInstance.logCardInputChanges else {
            return
        }
        
        self.log("End Editing: \(String(describing: field)) - CardValid: \(_cardView.isValid)", appendNewLine: false)
    }
    
    @objc func isValidChanged(_ form: OPPaymentCardDetailsForm, _ isValid: Bool) {
        guard TestHarnessSettings.sharedInstance.logFormValidChanges else {
            return
        }

        self.log("Form Is Valid: \(isValid)", appendNewLine: true)
    }

    @objc public func getCustomErrorMessage(for control: OPPaymentCardDetailsView, with field: OPCardField) -> String {
        var errorMessage: String? = nil
        
        switch field {
        case .number:
            if control.cardNumberIsEmpty {
                errorMessage = OPStrings.emptyCardNumberError
            } else if control.cardType == OPCardBrand.unsupported {
                errorMessage = OPStrings.unsupportedCardError
            } else if !control.cardNumberIsValid {
                errorMessage = OPStrings.invalidCardNumberError
            }
        case .expiration:
            if control.expirationIsEmpty {
                errorMessage = OPStrings.emptyExpirationError
            } else if !control.expirationIsValid {
                errorMessage = OPStrings.invalidExpirationError
            }
        case .cvc:
            if control.cvcIsEmpty {
                errorMessage = OPStrings.emptyCvcError
            } else if !control.cvcIsValid {
                errorMessage = OPStrings.invalidCvcError
            }
        case .postalCode:
            if control.postalCodeIsEmpty && control.postalCodeEntryEnabled {
                errorMessage = OPStrings.emptyPostalCodeError
            }
        case .unknown:
            if !control.isValid {
                errorMessage = OPStrings.generalCardError
            }
        }
        
        return errorMessage == nil ? "" : "Custom: \(errorMessage!)"
    }
    
    @objc func resetLog() { _logView.text = "" }
    
    func log(_ message : String?, prependNewLine: Bool = true, appendNewLine: Bool = true) {
        dispatchToMainThreadIfNecessary {
            if (prependNewLine) {
                self._logView.text += "\n"
            }
            
            if let unwrappedMessage = message {
                self._logView.text += unwrappedMessage
            }
            
            if (appendNewLine) {
                self._logView.text += "\n"
            }
            
            let bottom = NSMakeRange(self._logView.text.count - 1, 1)
            self._logView.scrollRangeToVisible(bottom)
        }
    }
}


