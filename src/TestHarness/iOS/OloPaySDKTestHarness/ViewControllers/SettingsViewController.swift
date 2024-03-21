// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  SettingsViewController.swift
//  OloPaySDKTestHarness
//
//  Created by Justin Anderson on 7/8/21.
//

import Foundation
import UIKit

enum SettingsType {
    case creditCard
    case digitalWallet
    case cvvToken
}

// NOTE: This needs to be refactored to use MVVM
class SettingsViewController : UIViewController, UITextFieldDelegate {
    var _settingsType: SettingsType = .creditCard
    var _navigationBar = UINavigationBar()
    var _scrollContent = UIScrollView()
    
    // Settings not controlled by Plist Values
    var _useMultiLinePaymentToggle = UISwitch()
    var _logCardInputToggle = UISwitch()
    var _displayCardErrorsToggle = UISwitch()
    var _customCardErrorMessagesToggle = UISwitch()
    var _displayPostalCodeToggle = UISwitch()
    var _useSingleLinePaymentToggle = UISwitch()
    var _logFormValidToggle = UISwitch()
    var _displayCvvErrorsToggle = UISwitch()
    var _logCvvChangesToggle = UISwitch()
    var _customCvvErrorsToggle = UISwitch()
    
    // Ordering API Settings
    var _completePaymentToggle = UISwitch()
    var _requireLoggedInUserLabel = UILabel()
    var _apiUrlTextField = UITextField()
    var _apiKeyTextField = UITextField()
    var _restaurantIdTextField = UITextField()
    var _productIdTextField = UITextField()
    var _productQtyTextField = UITextField()
    var _applePayBillingSchemeIdTextField = UITextField()
    
    // User Settings
    var _useLoggedInUser = UISwitch()
    var _userEmailTextField = UITextField()
    var _userPasswordTextField = UITextField()
    var _userSavedCardBillingAccountIdTextField = UITextField()
    
    @objc public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.view.backgroundColor = .systemBackground
        self.isModalInPresentation = true
    }
    
    public init(for type: SettingsType) {
        super.init(nibName: nil, bundle: nil)
        _settingsType = type
        self.view.backgroundColor = .systemBackground
        self.isModalInPresentation = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupViews()
    }
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    var onDismiss: (() -> Void) = {}
    
    func setUITestingIdentifiers() {
        _logCardInputToggle.accessibilityIdentifier = UITestingIdentifiers.Settings.logCardInputToggle
        _completePaymentToggle.accessibilityIdentifier = UITestingIdentifiers.Settings.completePaymentToggle
        _apiUrlTextField.accessibilityIdentifier = UITestingIdentifiers.Settings.apiUrlTextField
        _apiKeyTextField.accessibilityIdentifier = UITestingIdentifiers.Settings.apiKeyTextField
        _restaurantIdTextField.accessibilityIdentifier = UITestingIdentifiers.Settings.restaurantIdTextField
        _productIdTextField.accessibilityIdentifier = UITestingIdentifiers.Settings.productIdTextField
        _productQtyTextField.accessibilityIdentifier = UITestingIdentifiers.Settings.productQtyTextField
        _userEmailTextField.accessibilityIdentifier = UITestingIdentifiers.Settings.emailTextField
        _navigationBar.accessibilityIdentifier = UITestingIdentifiers.Settings.navigationBar
        _displayCardErrorsToggle.accessibilityIdentifier = UITestingIdentifiers.Settings.displayCardErrorsToggle
        _customCardErrorMessagesToggle.accessibilityIdentifier = UITestingIdentifiers.Settings.customCardErrorMessagesToggle
        _displayPostalCodeToggle.accessibilityIdentifier = UITestingIdentifiers.Settings.displayPostalCodeToggle
        _useSingleLinePaymentToggle.accessibilityIdentifier = UITestingIdentifiers.Settings.useCardViewPaymentToggle
        _useMultiLinePaymentToggle.accessibilityIdentifier = UITestingIdentifiers.Settings.useFormViewPaymentToggle
        _logFormValidToggle.accessibilityIdentifier = UITestingIdentifiers.Settings.logFormValidToggle
        _applePayBillingSchemeIdTextField.accessibilityIdentifier = UITestingIdentifiers.Settings.applePayBillingSchemeIdTextField
        _logCvvChangesToggle.accessibilityIdentifier = UITestingIdentifiers.Settings.logCvvChangesToggle
        _displayCvvErrorsToggle.accessibilityIdentifier = UITestingIdentifiers.Settings.displayCvvErrorsToggle
        _customCvvErrorsToggle.accessibilityIdentifier = UITestingIdentifiers.Settings.customCvvErrorMessagesToggle
        _useLoggedInUser.accessibilityIdentifier = UITestingIdentifiers.Settings.useLoggedInUserToggle
        _userPasswordTextField.accessibilityIdentifier = UITestingIdentifiers.Settings.userPasswordTextField
        _userSavedCardBillingAccountIdTextField.accessibilityIdentifier = UITestingIdentifiers.Settings.userSavedCardBillingSchemeIdTextField
    }
    
    func setupViews() {
        setUITestingIdentifiers()
        
        let navigationItem = UINavigationItem(title: "Olo Pay SDK: Settings")
        let settingsButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: nil, action: #selector(self.close))
        settingsButton.accessibilityIdentifier = UITestingIdentifiers.Settings.doneButton
        
        navigationItem.rightBarButtonItem = settingsButton
        _navigationBar.items = [navigationItem]
        
        createScrollingStack(scrollView: _scrollContent)
        
        let mainStack = UIStackView(arrangedSubviews: [_navigationBar, _scrollContent])
        mainStack.axis = NSLayoutConstraint.Axis.vertical
        mainStack.distribution = UIStackView.Distribution.fill
        mainStack.alignment = UIStackView.Alignment.fill
        
        self.view.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            mainStack.topAnchor.constraint(equalTo: view.topAnchor),
            mainStack.leftAnchor.constraint(equalTo: view.leftAnchor),
            mainStack.rightAnchor.constraint(equalTo: view.rightAnchor),
            mainStack.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            _scrollContent.topAnchor.constraint(equalTo: _navigationBar.bottomAnchor),
            _scrollContent.leftAnchor.constraint(equalTo: mainStack.leftAnchor),
            _scrollContent.rightAnchor.constraint(equalTo: mainStack.rightAnchor),
            _scrollContent.widthAnchor.constraint(equalTo: mainStack.widthAnchor),
            _scrollContent.bottomAnchor.constraint(equalTo: mainStack.bottomAnchor),
        ]
        
        NSLayoutConstraint.activate(constraints)
        updateFieldEnabledStatus()
    }
    
    func createScrollingStack(scrollView: UIScrollView) {
        let scrollStack = UIStackView()
        scrollStack.axis = NSLayoutConstraint.Axis.vertical
        scrollStack.distribution = UIStackView.Distribution.fill
        scrollStack.alignment = UIStackView.Alignment.fill
        scrollStack.spacing = 10
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.dismissKeyboard))
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        toolbar.items = [doneButton]
        
        if (_settingsType == .creditCard) {
            scrollStack.addArrangedSubview(createCreditCardStack())
        }
        
        if (_settingsType == .cvvToken) {
            scrollStack.addArrangedSubview(createCvvTokenStack())
        }
        
        scrollStack.addArrangedSubview(createOrderingApiStack(toolbar))
        scrollStack.addArrangedSubview(createUserStack(toolbar))
        
        scrollView.addSubview(scrollStack)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollStack.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            scrollStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollStack.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 10),
            scrollStack.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            scrollStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            scrollStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -20)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func createCreditCardStack() -> UIStackView {
        let cardStack = UIStackView()
        cardStack.axis = .vertical
        cardStack.distribution = .fill
        cardStack.alignment = .fill
        cardStack.spacing = 10
        
        //###########################
        //## Single-Line Section
        //###########################
        cardStack.addArrangedSubview(createSectionHeader(title: "Single-Line Credit Card Settings"))
        
        // Set up Use Single Line Input row
        setupToggle(toggle: _useSingleLinePaymentToggle, isOn: TestHarnessSettings.sharedInstance.useSingleLinePayment, action: #selector(useSingleLinePaymentToggled))
        let useSingleLineRow = createHorizontalStack(leftView: createLabel(title: "Use Single-Line Payment"), rightView: _useSingleLinePaymentToggle)
        cardStack.addArrangedSubview(useSingleLineRow)
        
        // Set up Log Card Input row
        setupToggle(toggle: _logCardInputToggle, isOn: TestHarnessSettings.sharedInstance.logCardInputChanges, action: #selector(cardInputToggled))
        let logCardInputRow = createHorizontalStack(leftView: createLabel(title: "Log Card Input Changes"), rightView: _logCardInputToggle)
        cardStack.addArrangedSubview(logCardInputRow)
        
        //Set up Display Postal Code
        setupToggle(toggle: _displayPostalCodeToggle, isOn: TestHarnessSettings.sharedInstance.displayPostalCode, action: #selector(displayPostalCodeToggled))
        let displayPostalCodeRow = createHorizontalStack(leftView: createLabel(title: "Display Postal Code"), rightView: _displayPostalCodeToggle)
        cardStack.addArrangedSubview(displayPostalCodeRow)
        
        //Set up Display Card Errors UI
        setupToggle(toggle: _displayCardErrorsToggle, isOn: TestHarnessSettings.sharedInstance.displayCardErrors, action: #selector(displayCardErrorsToggled))
        let displayCardErrorsRow = createHorizontalStack(leftView: createLabel(title: "Display Card Errors"), rightView: _displayCardErrorsToggle)
        cardStack.addArrangedSubview(displayCardErrorsRow)
        
        //Set up Use Custom Error Messages
        setupToggle(toggle: _customCardErrorMessagesToggle, isOn: TestHarnessSettings.sharedInstance.customCardErrorMessages, action: #selector(customCardErrorMessagesToggled))
        let customCardErrorMessagesRow = createHorizontalStack(leftView: createLabel(title: "Use Custom Card Error Messages"), rightView: _customCardErrorMessagesToggle)
        cardStack.addArrangedSubview(customCardErrorMessagesRow)
        
        //###########################
        //## Multi-Line Section
        //###########################
        cardStack.addArrangedSubview(createSectionHeader(title: "Multi-Line Credit Card Settings"))
        
        // Set up Use Multiline Payment Row
        setupToggle(toggle: _useMultiLinePaymentToggle, isOn: !TestHarnessSettings.sharedInstance.useSingleLinePayment, action: #selector(useMultiLinePaymentToggled))
        let multiLinePaymentRow = createHorizontalStack(leftView: createLabel(title: "Use Multi-Line Payment"), rightView: _useMultiLinePaymentToggle)
        cardStack.addArrangedSubview(multiLinePaymentRow)

        // Set up Log Form Valid Row
        setupToggle(toggle: _logFormValidToggle, isOn: TestHarnessSettings.sharedInstance.logFormValidChanges, action: #selector(logFormValidToggled))
        let logFormValidRow = createHorizontalStack(leftView: createLabel(title: "Log Form Valid Changes"), rightView: _logFormValidToggle)
        cardStack.addArrangedSubview(logFormValidRow)
        
        return cardStack
    }
    
    func createCvvTokenStack() -> UIStackView {
        let cvvStack = UIStackView()
        cvvStack.axis = .vertical
        cvvStack.distribution = .fill
        cvvStack.alignment = .fill
        cvvStack.spacing = 10
        
        cvvStack.addArrangedSubview(createSectionHeader(title: "CVV Token Settings"))
        
        // Set up Log CVV Input row
        setupToggle(toggle: _logCvvChangesToggle, isOn: TestHarnessSettings.sharedInstance.logCvvInputChanges, action: #selector(logCvvInputToggled))
        let logCvvInputRow = createHorizontalStack(leftView: createLabel(title: "Log CVV Input Changes"), rightView: _logCvvChangesToggle)
        cvvStack.addArrangedSubview(logCvvInputRow)
        
        //Set up Display Card Errors UI
        setupToggle(toggle: _displayCvvErrorsToggle, isOn: TestHarnessSettings.sharedInstance.displayCvvErrors, action: #selector(displayCvvErrorsToggled))
        let displayCvvErrorsRow = createHorizontalStack(leftView: createLabel(title: "Display CVV Errors"), rightView: _displayCvvErrorsToggle)
        cvvStack.addArrangedSubview(displayCvvErrorsRow)
        
        //Set up Use Custom Error Messages
        setupToggle(toggle: _customCvvErrorsToggle, isOn: TestHarnessSettings.sharedInstance.customCvvErrorMessages, action: #selector(customCvvErrorMessagesToggled))
        let customCvvErrorMessagesRow = createHorizontalStack(leftView: createLabel(title: "Use Custom CVV Error Messages"), rightView: _customCvvErrorsToggle)
        cvvStack.addArrangedSubview(customCvvErrorMessagesRow)
        
        return cvvStack
    }
    
    func createOrderingApiStack(_ toolbar: UIToolbar) -> UIStackView {
        let apiStack = UIStackView()
        apiStack.axis = .vertical
        apiStack.distribution = .fill
        apiStack.alignment = .fill
        apiStack.spacing = 10
        
        apiStack.addArrangedSubview(createSectionHeader(title: "Ordering API Settings"))
        
        // Set up Complete Payment row
        setupToggle(toggle: _completePaymentToggle, isOn: TestHarnessSettings.sharedInstance.completeOloPayPayment, action: #selector(completePaymentToggled))
        let completePaymentRow = createHorizontalStack(leftView: createLabel(title: "Create Basket & Complete Payment"), rightView: _completePaymentToggle)
        apiStack.addArrangedSubview(completePaymentRow)
        
        // Set up logged in user warning
        _requireLoggedInUserLabel.text = "(CVV Payments require logged in user)"
        _requireLoggedInUserLabel.textColor = .systemRed
        _requireLoggedInUserLabel.textAlignment = .center
        _requireLoggedInUserLabel.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 12))
        apiStack.addArrangedSubview(_requireLoggedInUserLabel)
        
        // Set up API URL row
        setupTextField(field: _apiUrlTextField, toolbar: toolbar, text: TestHarnessSettings.sharedInstance.baseAPIUrl)
        let apiUrlRow = createHorizontalStack(leftView: createLabel(title: "API URL"), rightView: _apiUrlTextField)
        apiStack.addArrangedSubview(apiUrlRow)
        
        // Set up API Key row
        setupTextField(field: _apiKeyTextField, toolbar: toolbar, text: TestHarnessSettings.sharedInstance.apiKey)
        let apiKeyRow = createHorizontalStack(leftView: createLabel(title: "API Key"), rightView: _apiKeyTextField)
        apiStack.addArrangedSubview(apiKeyRow)
        
        // Set up Restaurant ID row
        setupTextField(field: _restaurantIdTextField, toolbar: toolbar, text: nil)
        _restaurantIdTextField.keyboardType = UIKeyboardType.numberPad
        _restaurantIdTextField.delegate = self
        if TestHarnessSettings.sharedInstance.restaurantId != nil {
            _restaurantIdTextField.text = String(TestHarnessSettings.sharedInstance.restaurantId!)
        }
        let restaurantIdRow = createHorizontalStack(leftView: createLabel(title: "Restaurant ID"), rightView: _restaurantIdTextField)
        apiStack.addArrangedSubview(restaurantIdRow)
        
        // Set up Product ID row
        setupTextField(field: _productIdTextField, toolbar: toolbar, text: nil)
        _productIdTextField.keyboardType = UIKeyboardType.numberPad
        _productIdTextField.delegate = self
        if TestHarnessSettings.sharedInstance.productId != nil {
            _productIdTextField.text = String(TestHarnessSettings.sharedInstance.productId!)
        }
        let productIdRow = createHorizontalStack(leftView: createLabel(title: "Product ID"), rightView: _productIdTextField)
        apiStack.addArrangedSubview(productIdRow)
        
        // Set up Product Qty row
        setupTextField(field: _productQtyTextField, toolbar: toolbar, text: nil)
        _productQtyTextField.keyboardType = UIKeyboardType.numberPad
        _productQtyTextField.delegate = self
        if TestHarnessSettings.sharedInstance.productQty != nil {
            _productQtyTextField.text = String(TestHarnessSettings.sharedInstance.productQty!)
        }
        let productQtyRow = createHorizontalStack(leftView: createLabel(title: "Product Qty"), rightView: _productQtyTextField)
        apiStack.addArrangedSubview(productQtyRow)
        
        
        // Set up Apple Pay billing scheme Id row
        if (_settingsType == .digitalWallet) {
            setupTextField(field: _applePayBillingSchemeIdTextField, toolbar: toolbar, text: String(TestHarnessSettings.sharedInstance.applePayBillingSchemeId ?? ""))
            _applePayBillingSchemeIdTextField.keyboardType = UIKeyboardType.numberPad
            _applePayBillingSchemeIdTextField.delegate = self
            
            let schemeRow = createHorizontalStack(leftView: createLabel(title: "Apple Pay Billing Scheme Id"), rightView: _applePayBillingSchemeIdTextField)
            apiStack.addArrangedSubview(schemeRow)
        }
        
        return apiStack
    }
    
    func createUserStack(_ toolbar: UIToolbar) -> UIStackView {
        let userStack = UIStackView()
        userStack.axis = .vertical
        userStack.distribution = .fill
        userStack.alignment = .fill
        userStack.spacing = 10
        
        userStack.addArrangedSubview(createSectionHeader(title: "User API Settings"))
        
        // Set up user type row
        setupToggle(toggle: _useLoggedInUser, isOn: TestHarnessSettings.sharedInstance.useLoggedInUser, action: #selector(loggedInUserToggled))
        let guestUserRow = createHorizontalStack(leftView: createLabel(title: "Use Logged In User"), rightView: _useLoggedInUser)
        userStack.addArrangedSubview(guestUserRow)
        
        // Set up user email row
        setupTextField(field: _userEmailTextField, toolbar: toolbar, text: String(TestHarnessSettings.sharedInstance.userEmail ?? ""))
        _userEmailTextField.keyboardType = UIKeyboardType.emailAddress
        let emailRow = createHorizontalStack(leftView: createLabel(title: "Email"), rightView: _userEmailTextField)
        userStack.addArrangedSubview(emailRow)
        
        // Set up user password
        setupTextField(field: _userPasswordTextField, toolbar: toolbar, text: String(TestHarnessSettings.sharedInstance.userPassword ?? ""))
        _userPasswordTextField.isSecureTextEntry = true
        let passwordRow = createHorizontalStack(leftView: createLabel(title: "Password"), rightView: _userPasswordTextField)
        userStack.addArrangedSubview(passwordRow)
        
        if _settingsType == .cvvToken {
            setupTextField(field: _userSavedCardBillingAccountIdTextField, toolbar: toolbar, text: String(TestHarnessSettings.sharedInstance.savedCardBillingAccountId ?? ""))
            _userSavedCardBillingAccountIdTextField.keyboardType = UIKeyboardType.numberPad
            _userSavedCardBillingAccountIdTextField.delegate = self
            
            let schemeRow = createHorizontalStack(leftView: createLabel(title: "Saved Card Billing Account Id"), rightView: _userSavedCardBillingAccountIdTextField)
            userStack.addArrangedSubview(schemeRow)
        }
        
        return userStack
    }
    
    func createHorizontalStack(leftView: UIView, rightView: UIView) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [leftView, rightView])
        stack.axis = NSLayoutConstraint.Axis.horizontal
        stack.distribution = UIStackView.Distribution.fill
        stack.alignment = UIStackView.Alignment.fill
        stack.spacing = 10
        
        return stack
    }
    
    func setupTextField(field: UITextField, toolbar: UIToolbar, text: String?) {
        field.borderStyle = .roundedRect
        field.inputAccessoryView = toolbar
        field.text = text ?? ""
        field.textColor = .label
        field.setContentHuggingPriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.horizontal)
        field.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: NSLayoutConstraint.Axis.horizontal)
    }
    
    func createLabel(title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.textColor = .label
        label.setContentHuggingPriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        return label
    }
    
    func setupToggle(toggle: UISwitch, isOn: Bool?, action: Selector) {
        toggle.addTarget(self, action: action, for: .touchUpInside)
        toggle.isOn = isOn ?? false
        toggle.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: NSLayoutConstraint.Axis.horizontal)
        toggle.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.horizontal)
        toggle.contentHorizontalAlignment = .right
    }
    
    func createSectionHeader(title: String) -> UILabel {
        let header = UILabel()
        header.text = title
        header.textColor = .systemGray6
        header.backgroundColor = UIColor.systemGray
        header.font = UIFont.boldSystemFont(ofSize: 22)
        header.textAlignment = .center
        return header
    }
    
    @objc func close() {
        TestHarnessSettings.sharedInstance.baseAPIUrl = _apiUrlTextField.text
        TestHarnessSettings.sharedInstance.apiKey = _apiKeyTextField.text
        
        if let restaurantIdString = _restaurantIdTextField.text, let restaurantId = UInt64(restaurantIdString) {
            TestHarnessSettings.sharedInstance.restaurantId = restaurantId
        }
        
        if let productIdString = _productIdTextField.text, let productId = UInt64(productIdString) {
            TestHarnessSettings.sharedInstance.productId = productId
        }
        
        if let productQtyString = _productQtyTextField.text, let productQty = UInt(productQtyString) {
            TestHarnessSettings.sharedInstance.productQty = productQty
        }
        
        if let email = _userEmailTextField.text {
            TestHarnessSettings.sharedInstance.userEmail = email
        }
        
        if let password = _userPasswordTextField.text {
            TestHarnessSettings.sharedInstance.userPassword = password
        }
        
        if let savedCardBillingAccount = _userSavedCardBillingAccountIdTextField.text, _settingsType == .cvvToken {
            TestHarnessSettings.sharedInstance.savedCardBillingAccountId = savedCardBillingAccount
        }
        
        if _settingsType == .digitalWallet, let billingScheme = _applePayBillingSchemeIdTextField.text {
            TestHarnessSettings.sharedInstance.applePayBillingSchemeId = billingScheme
        }
        
        onDismiss()
        TestHarnessSettings.sharedInstance.notifySettingsChanged()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func dismissKeyboard() {
        _apiUrlTextField.resignFirstResponder()
        _apiKeyTextField.resignFirstResponder()
        _restaurantIdTextField.resignFirstResponder()
        _productIdTextField.resignFirstResponder()
        _productQtyTextField.resignFirstResponder()
        _userEmailTextField.resignFirstResponder()
        _userPasswordTextField.resignFirstResponder()
        _userSavedCardBillingAccountIdTextField.resignFirstResponder()
    }
    
    @objc func displayCardErrorsToggled() {
        TestHarnessSettings.sharedInstance.displayCardErrors = _displayCardErrorsToggle.isOn
    }
    
    @objc func customCardErrorMessagesToggled() {
        TestHarnessSettings.sharedInstance.customCardErrorMessages = _customCardErrorMessagesToggle.isOn
    }
    
    @objc func displayPostalCodeToggled() {
        TestHarnessSettings.sharedInstance.displayPostalCode = _displayPostalCodeToggle.isOn
    }
    
    @objc func cardInputToggled() {
        TestHarnessSettings.sharedInstance.logCardInputChanges = _logCardInputToggle.isOn
    }
    
    @objc func logCvvInputToggled() {
        TestHarnessSettings.sharedInstance.logCvvInputChanges = _logCvvChangesToggle.isOn
    }
    
    @objc func loggedInUserToggled() {
        TestHarnessSettings.sharedInstance.useLoggedInUser = _useLoggedInUser.isOn
        updateFieldEnabledStatus()
    }
    
    @objc func displayCvvErrorsToggled() {
        TestHarnessSettings.sharedInstance.displayCvvErrors = _displayCvvErrorsToggle.isOn
    }
    
    @objc func customCvvErrorMessagesToggled() {
        TestHarnessSettings.sharedInstance.customCvvErrorMessages = _customCvvErrorsToggle.isOn
    }
    
    @objc func completePaymentToggled() {
        let completePayment = _completePaymentToggle.isOn
        TestHarnessSettings.sharedInstance.completeOloPayPayment = completePayment
        updateFieldEnabledStatus()
    }
    
    func updateFieldEnabledStatus() {
        let completePayment = TestHarnessSettings.sharedInstance.completeOloPayPayment
        let useLoggedInUser = TestHarnessSettings.sharedInstance.useLoggedInUser
        
        // Update Ordering API Settings
        setTextFieldEnabled(_apiUrlTextField, completePayment)
        setTextFieldEnabled(_apiKeyTextField, completePayment)
        setTextFieldEnabled(_restaurantIdTextField, completePayment)
        setTextFieldEnabled(_productIdTextField, completePayment)
        setTextFieldEnabled(_productQtyTextField, completePayment)
        
        if (_settingsType == .cvvToken) {
            let showLabel = completePayment && !useLoggedInUser
            _requireLoggedInUserLabel.isHidden = !showLabel
        } else {
            _requireLoggedInUserLabel.isHidden = true
        }
        
        if _settingsType == .digitalWallet {
            setTextFieldEnabled(_applePayBillingSchemeIdTextField, completePayment)
        }
        
        setToggleFieldEnabled(_useLoggedInUser, completePayment)
        setTextFieldEnabled(_userEmailTextField, completePayment)
        setTextFieldEnabled(_userPasswordTextField, completePayment && useLoggedInUser)
        setTextFieldEnabled(_userSavedCardBillingAccountIdTextField, completePayment && useLoggedInUser)
    }
    
    func setTextFieldEnabled(_ textField: UITextField, _ isEnabled: Bool) {
        textField.isEnabled = isEnabled
        textField.backgroundColor = isEnabled ? .secondarySystemFill : .systemBackground
        textField.textColor = isEnabled ? .label : .secondaryLabel
    }
    
    func setToggleFieldEnabled(_ toggleField: UISwitch, _ isEnabled: Bool) {
        toggleField.isEnabled = isEnabled
    }
    
    @objc func useSingleLinePaymentToggled() {
        let useSingleLine = _useSingleLinePaymentToggle.isOn
        TestHarnessSettings.sharedInstance.useSingleLinePayment = useSingleLine
        
        updateSingleLineSettingsEnabledState(singleLineEnabled: useSingleLine)
    }
    
    @objc func useMultiLinePaymentToggled() {
        let useMultiLine = _useMultiLinePaymentToggle.isOn
        TestHarnessSettings.sharedInstance.useSingleLinePayment = !useMultiLine
        
        updateSingleLineSettingsEnabledState(singleLineEnabled: !useMultiLine)
    }

    @objc func logFormValidToggled() {
        let logFormValid = _logFormValidToggle.isOn
        TestHarnessSettings.sharedInstance.logFormValidChanges = logFormValid
    }
    
    @objc func updateSingleLineSettingsEnabledState(singleLineEnabled: Bool) {
        // Single line settings
        _useSingleLinePaymentToggle.isOn = singleLineEnabled
        _logCardInputToggle.isEnabled = singleLineEnabled
        _displayPostalCodeToggle.isEnabled = singleLineEnabled
        _displayCardErrorsToggle.isEnabled = singleLineEnabled
        _displayCardErrorsToggle.isEnabled = singleLineEnabled
        _customCardErrorMessagesToggle.isEnabled = singleLineEnabled

        // Multi line settings
        _useMultiLinePaymentToggle.isOn = !singleLineEnabled
        _logFormValidToggle.isEnabled = !singleLineEnabled
    }
    
    @objc private func keyboardWillShow(notification: NSNotification){
        guard let keyboardFrame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        _scrollContent.contentInset.bottom = view.convert(keyboardFrame.cgRectValue, from: nil).size.height
    }

    @objc private func keyboardWillHide(notification: NSNotification){
        _scrollContent.contentInset.bottom = 0
    }

    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard !string.isEmpty else {
            return true
        }

        if textField.keyboardType == .numberPad {
            if CharacterSet(charactersIn: "0123456789").isSuperset(of: CharacterSet(charactersIn: string)) {
                return true
            }
        }

        return false
    }
}
