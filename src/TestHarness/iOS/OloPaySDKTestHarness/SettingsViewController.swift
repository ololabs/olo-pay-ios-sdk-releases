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

class SettingsViewController : UIViewController, UITextFieldDelegate {
    var _logCardInputToggle = UISwitch()
    var _completePaymentToggle = UISwitch()
    var _apiUrlTextField = UITextField()
    var _apiKeyTextField = UITextField()
    var _restaurantIdTextField = UITextField()
    var _productIdTextField = UITextField()
    var _productQtyTextField = UITextField()
    var _emailTextField = UITextField()
    var _applePayBillingSchemeIdTextField = UITextField()
    var _navigationBar = UINavigationBar()
    var _displayCardErrorsToggle = UISwitch()
    var _customCardErrorMessagesToggle = UISwitch()
    var _displayPostalCodeToggle = UISwitch()
    var _scrollContent = UIScrollView()
    var _useSingleLinePaymentToggle = UISwitch()
    var _useMultiLinePaymentToggle = UISwitch()
    var _logFormValidToggle = UISwitch()
    
    @objc public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.view.backgroundColor = .systemBackground
        self.isModalInPresentation = true
    }
    
    public init() {
        super.init(nibName: nil, bundle: nil)
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
        _emailTextField.accessibilityIdentifier = UITestingIdentifiers.Settings.emailTextField
        _navigationBar.accessibilityIdentifier = UITestingIdentifiers.Settings.navigationBar
        _displayCardErrorsToggle.accessibilityIdentifier = UITestingIdentifiers.Settings.displayCardErrorsToggle
        _customCardErrorMessagesToggle.accessibilityIdentifier = UITestingIdentifiers.Settings.customCardErrorMessagesToggle
        _displayPostalCodeToggle.accessibilityIdentifier = UITestingIdentifiers.Settings.displayPostalCodeToggle
        _useSingleLinePaymentToggle.accessibilityIdentifier = UITestingIdentifiers.Settings.useCardViewPaymentToggle
        _useMultiLinePaymentToggle.accessibilityIdentifier = UITestingIdentifiers.Settings.useFormViewPaymentToggle
        _logFormValidToggle.accessibilityIdentifier = UITestingIdentifiers.Settings.logFormValidToggle
        _applePayBillingSchemeIdTextField.accessibilityIdentifier = UITestingIdentifiers.Settings.applePayBillingSchemeIdTextField
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
        
        createSingleLinePaymentSection(scrollStack)
        createMultiLinePaymentSection(scrollStack)
        createOrderingApiSection(scrollStack, toolbar)
        
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
        
        //Set initial enabled/disabled states of controls
        useSingleLinePaymentToggled()
        completePaymentToggled()
    }
    
    func createSingleLinePaymentSection(_ scrollStack: UIStackView) {
        scrollStack.addArrangedSubview(createSectionHeader(title: "Single-Line Payment Settings"))
        
        // Set up Log Card Input row
        setupToggle(toggle: _useSingleLinePaymentToggle, isOn: TestHarnessSettings.sharedInstance.useSingleLinePayment, action: #selector(useSingleLinePaymentToggled))
        let singleLinePaymentRow = createHorizontalStack(leftView: createLabel(title: "Use Single-Line Payment"), rightView: _useSingleLinePaymentToggle)
        scrollStack.addArrangedSubview(singleLinePaymentRow)
        
        // Set up Log Card Input row
        setupToggle(toggle: _logCardInputToggle, isOn: TestHarnessSettings.sharedInstance.logCardInputChanges, action: #selector(cardInputToggled))
        let logCardInputRow = createHorizontalStack(leftView: createLabel(title: "Log Card Input Changes"), rightView: _logCardInputToggle)
        scrollStack.addArrangedSubview(logCardInputRow)
        
        //Set up Display Postal Code
        setupToggle(toggle: _displayPostalCodeToggle, isOn: TestHarnessSettings.sharedInstance.displayPostalCode, action: #selector(displayPostalCodeToggled))
        let displayPostalCodeRow = createHorizontalStack(leftView: createLabel(title: "Display Postal Code"), rightView: _displayPostalCodeToggle)
        scrollStack.addArrangedSubview(displayPostalCodeRow)
        
        //Set up Use Default Card Error UI
        setupToggle(toggle: _displayCardErrorsToggle, isOn: TestHarnessSettings.sharedInstance.displayCardErrors, action: #selector(displayCardErrorsToggled))
        let displayCardErrorsRow = createHorizontalStack(leftView: createLabel(title: "Display Card Errors"), rightView: _displayCardErrorsToggle)
        scrollStack.addArrangedSubview(displayCardErrorsRow)
        
        //Set up Use Custom Error Messages
        setupToggle(toggle: _customCardErrorMessagesToggle, isOn: TestHarnessSettings.sharedInstance.customCardErrorMessages, action: #selector(customCardErrorMessagesToggled))
        let customCardErrorMessagesRow = createHorizontalStack(leftView: createLabel(title: "Use Custom Card Error Messages"), rightView: _customCardErrorMessagesToggle)
        scrollStack.addArrangedSubview(customCardErrorMessagesRow)
        scrollStack.setCustomSpacing(30, after: customCardErrorMessagesRow)
    }
    
    func createMultiLinePaymentSection(_ scrollStack: UIStackView) {
        scrollStack.addArrangedSubview(createSectionHeader(title: "Multi-Line Payment Settings"))
        
        // Set up Use Multiline Payment Row
        setupToggle(toggle: _useMultiLinePaymentToggle, isOn: !TestHarnessSettings.sharedInstance.useSingleLinePayment, action: #selector(useMultiLinePaymentToggled))
        let multiLinePaymentRow = createHorizontalStack(leftView: createLabel(title: "Use Multi-Line Payment"), rightView: _useMultiLinePaymentToggle)
        scrollStack.addArrangedSubview(multiLinePaymentRow)

        // Set up Log Form Valid Row
        setupToggle(toggle: _logFormValidToggle, isOn: TestHarnessSettings.sharedInstance.logFormValidChanges, action: #selector(logFormValidToggled))
        let logFormValidRow = createHorizontalStack(leftView: createLabel(title: "Log Form Valid Changes"), rightView: _logFormValidToggle)
        scrollStack.addArrangedSubview(logFormValidRow)
    }
    
    func createOrderingApiSection(_ scrollStack: UIStackView, _ toolbar: UIToolbar) {
        let header = createSectionHeader(title: "Ordering API Settings")
        scrollStack.addArrangedSubview(header)
        
        // Set up Complete Payment row
        setupToggle(toggle: _completePaymentToggle, isOn: TestHarnessSettings.sharedInstance.completeOloPayPayment, action: #selector(completePaymentToggled))
        let completePaymentRow = createHorizontalStack(leftView: createLabel(title: "Create Basket & Complete Payment"), rightView: _completePaymentToggle)
        scrollStack.addArrangedSubview(completePaymentRow)
        
        // Set up email row
        setupTextField(field: _emailTextField, toolbar: toolbar, text: String(TestHarnessSettings.sharedInstance.userEmail ?? ""))
        _emailTextField.keyboardType = UIKeyboardType.emailAddress
        let emailRow = createHorizontalStack(leftView: createLabel(title: "Email"), rightView: _emailTextField)
        scrollStack.addArrangedSubview(emailRow)
        
        // Set up API URL row
        setupTextField(field: _apiUrlTextField, toolbar: toolbar, text: TestHarnessSettings.sharedInstance.baseAPIUrl)
        let apiUrlRow = createHorizontalStack(leftView: createLabel(title: "API URL"), rightView: _apiUrlTextField)
        scrollStack.addArrangedSubview(apiUrlRow)
        
        // Set up API Key row
        setupTextField(field: _apiKeyTextField, toolbar: toolbar, text: TestHarnessSettings.sharedInstance.apiKey)
        let apiKeyRow = createHorizontalStack(leftView: createLabel(title: "API Key"), rightView: _apiKeyTextField)
        scrollStack.addArrangedSubview(apiKeyRow)
        
        // Set up Restaurant ID row
        setupTextField(field: _restaurantIdTextField, toolbar: toolbar, text: nil)
        _restaurantIdTextField.keyboardType = UIKeyboardType.numberPad
        _restaurantIdTextField.delegate = self
        if TestHarnessSettings.sharedInstance.restaurantId != nil {
            _restaurantIdTextField.text = String(TestHarnessSettings.sharedInstance.restaurantId!)
        }
        let restaurantIdRow = createHorizontalStack(leftView: createLabel(title: "Restaurant ID"), rightView: _restaurantIdTextField)
        scrollStack.addArrangedSubview(restaurantIdRow)
        
        // Set up Product ID row
        setupTextField(field: _productIdTextField, toolbar: toolbar, text: nil)
        _productIdTextField.keyboardType = UIKeyboardType.numberPad
        _productIdTextField.delegate = self
        if TestHarnessSettings.sharedInstance.productId != nil {
            _productIdTextField.text = String(TestHarnessSettings.sharedInstance.productId!)
        }
        let productIdRow = createHorizontalStack(leftView: createLabel(title: "Product ID"), rightView: _productIdTextField)
        scrollStack.addArrangedSubview(productIdRow)
        
        // Set up Product Qty row
        setupTextField(field: _productQtyTextField, toolbar: toolbar, text: nil)
        _productQtyTextField.keyboardType = UIKeyboardType.numberPad
        _productQtyTextField.delegate = self
        if TestHarnessSettings.sharedInstance.productQty != nil {
            _productQtyTextField.text = String(TestHarnessSettings.sharedInstance.productQty!)
        }
        let productQtyRow = createHorizontalStack(leftView: createLabel(title: "Product Qty"), rightView: _productQtyTextField)
        scrollStack.addArrangedSubview(productQtyRow)
        
        
        // Set up Apple Pay billing scheme Id row
        setupTextField(field: _applePayBillingSchemeIdTextField, toolbar: toolbar, text: String(TestHarnessSettings.sharedInstance.applePayBillingSchemeId ?? ""))
        _applePayBillingSchemeIdTextField.keyboardType = UIKeyboardType.numberPad
        _applePayBillingSchemeIdTextField.delegate = self
        let schemeRow = createHorizontalStack(leftView: createLabel(title: "Apple Pay Billing Scheme Id"), rightView: _applePayBillingSchemeIdTextField)
        scrollStack.addArrangedSubview(schemeRow)
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
        
        if let email = _emailTextField.text {
            TestHarnessSettings.sharedInstance.userEmail = email
        }
        
        if let billingScheme = _applePayBillingSchemeIdTextField.text {
            TestHarnessSettings.sharedInstance.applePayBillingSchemeId = billingScheme
        }
        
        onDismiss()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func dismissKeyboard() {
        _apiUrlTextField.resignFirstResponder()
        _apiKeyTextField.resignFirstResponder()
        _restaurantIdTextField.resignFirstResponder()
        _productIdTextField.resignFirstResponder()
        _productQtyTextField.resignFirstResponder()
        _emailTextField.resignFirstResponder()
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
    
    @objc func completePaymentToggled() {
        let completePayment = _completePaymentToggle.isOn
        TestHarnessSettings.sharedInstance.completeOloPayPayment = completePayment
        setTextFieldEnabled(textField: _emailTextField, isEnabled: completePayment)
        setTextFieldEnabled(textField: _apiUrlTextField, isEnabled: completePayment)
        setTextFieldEnabled(textField: _apiKeyTextField, isEnabled: completePayment)
        setTextFieldEnabled(textField: _restaurantIdTextField, isEnabled: completePayment)
        setTextFieldEnabled(textField: _productIdTextField, isEnabled: completePayment)
        setTextFieldEnabled(textField: _productQtyTextField, isEnabled: completePayment)
    }
    
    func setTextFieldEnabled(textField: UITextField, isEnabled: Bool) {
        textField.isEnabled = isEnabled
        textField.backgroundColor = isEnabled ? .secondarySystemFill : .systemBackground
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
