// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  CardInputViewController.swift
//  OloPaySDKTestHarness
//
//  Created by Justin Anderson on 8/11/23.
//

import Foundation
import UIKit
import OloPaySDK

class CardInputViewController : UIViewController, CardInputViewModelDelegate, ViewControllerWithSettingsProtocol {
    private let _formSubmitHeader = "---------- FORM DETAILS SUBMISSION ----------"
    private let _cardSubmitHeader = "---------- CARD DETAILS SUBMISSION ----------"
    private let _viewModel: CardInputViewModel
    
    private let _submitButton = UIButton()
    var _clearButton = UIButton()
    var _clearFocusButton = UIButton()
    private let _navigationBar = UINavigationBar()
    private let _paymentStack = UIStackView()
    private var _paymentView : UIView? = nil
    private let _cardView = OPPaymentCardDetailsView()
    private let _formView = OPPaymentCardDetailsForm()
    private let _logViewController: LogViewController
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(viewModel: CardInputViewModel) {
        _viewModel = viewModel
        _logViewController = LogViewController(viewModel: _viewModel.logViewModel)
        _paymentView = _cardView
        
        super.init(nibName: nil, bundle: nil)
        
        _viewModel.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _paymentStack.axis = NSLayoutConstraint.Axis.vertical
        _paymentStack.distribution = UIStackView.Distribution.fill
        _paymentStack.alignment = UIStackView.Alignment.fill
        
        // Set up keyboard done button for input fields
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.dismissKeyboard))
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        toolbar.items = [doneButton]
        
        _cardView.inputAccessoryView = toolbar
        _cardView.accessibilityIdentifier = UITestingIdentifiers.TestHarness.cardView
        _cardView.cardDetailsDelegate = _viewModel
        _cardView.backgroundColor = .white
        _cardView.countryCode = "US"
        
        _formView.accessibilityIdentifier = UITestingIdentifiers.TestHarness.formView
        _formView.cardDetailsDelegate = _viewModel
        _formView.backgroundColor = .white
        
        // Set up card submission button
        _submitButton.setTitle("Submit", for: .normal)
        _submitButton.backgroundColor = .systemBlue
        _submitButton.setTitleColor(UIColor.white, for: .normal)
        _submitButton.setTitleColor(UIColor.darkGray, for: .disabled)
        _submitButton.addTarget(self, action: #selector(submit), for: .touchUpInside)
        _submitButton.accessibilityIdentifier = UITestingIdentifiers.TestHarness.submitButton
        
        _clearButton.setTitle("Clear Card", for: .normal)
        _clearButton.backgroundColor = .white
        _clearButton.addTarget(self, action: #selector(clear), for: .touchUpInside)
        _clearButton.layer.borderWidth = 2
        _clearButton.layer.borderColor = UIColor.systemBlue.cgColor
        _clearButton.setTitleColor(UIColor.systemBlue, for: .normal)
        _clearButton.setTitleColor(UIColor.darkGray, for: .disabled)
        
        _clearFocusButton.setTitle("Clear Focus", for: .normal)
        _clearFocusButton.backgroundColor = .white
        _clearFocusButton.addTarget(self, action: #selector(clearFocus), for: .touchUpInside)
        _clearFocusButton.layer.borderWidth = 2
        _clearFocusButton.layer.borderColor = UIColor.systemBlue.cgColor
        _clearFocusButton.setTitleColor(UIColor.systemBlue, for: .normal)
        _clearFocusButton.setTitleColor(UIColor.darkGray, for: .disabled)
        
        // Set up constraints
        let positiveViewSpacing: CGFloat = 10.0
        let negativeViewSpacing: CGFloat = -10.0
        
        let buttonStack = UIStackView(arrangedSubviews: [_submitButton, _clearButton, _clearFocusButton])
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.alignment = .fill
        buttonStack.spacing = positiveViewSpacing
        
        loadSettings(settings: _viewModel.allSettings)
        let mainStack = UIStackView(arrangedSubviews: [_paymentStack, buttonStack, _logViewController.view])
        mainStack.axis = .vertical
        mainStack.distribution = .fill
        mainStack.alignment = .fill
        mainStack.spacing = positiveViewSpacing
        
        view.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        _paymentStack.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            mainStack.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1.0),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            _paymentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: positiveViewSpacing),
            _paymentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: negativeViewSpacing),
            
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: positiveViewSpacing),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: negativeViewSpacing),
            
            _logViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: positiveViewSpacing),
            _logViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: negativeViewSpacing),
            _logViewController.view.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        self.addChild(_logViewController)
        _logViewController.didMove(toParent: self)
    }
    
    private func updatePaymentStack(useSingleLinePayment: Bool) {
        guard let paymentView = _paymentView else {
            return
        }
        paymentView.removeFromSuperview()
        
        if useSingleLinePayment {
            _paymentView = _cardView
        } else {
            _paymentView = _formView
        }
        
        _paymentStack.addArrangedSubview(_paymentView!)
    }
    
    @objc func settingsClicked() {
        _cardView.resignFirstResponder()
        let _ = _formView.resignFirstResponder()
        self.present(SettingsViewController(for: .creditCard), animated: true)
    }
    
    @objc func submit() {
        if _viewModel.allSettings.useSingleLinePayment {
            submitCard()
        } else {
            submitForm()
        }
    }
    
    @objc func clear() {
        _cardView.clear()
    }
    
    @objc func clearFocus() {
        let _ = _cardView.resignFirstResponder()
    }
    
    @objc func dismissKeyboard() {
        _cardView.resignFirstResponder()
    }
    
    func settingsChanged(settings: TestHarnessSettingsProtocol) {
        loadSettings(settings: settings)
    }
    
    private func loadSettings(settings: TestHarnessSettingsProtocol) {
        _cardView.clear()
        _cardView.displayGeneratedErrorMessages = settings.displayCardErrors
        _cardView.postalCodeEntryEnabled = settings.displayPostalCode
        OPPaymentCardDetailsView.errorMessageHandler = settings.customCardErrorMessages ? _viewModel.customErrorMessagehandler(_:_:_:) : nil
        
        updatePaymentStack(useSingleLinePayment: settings.useSingleLinePayment)
        _clearButton.isHidden = !settings.useSingleLinePayment
        _clearFocusButton.isHidden = !settings.useSingleLinePayment
    }
    
    @objc func submitCard() {
        _viewModel.log(_cardSubmitHeader, prependNewLine: true, appendNewLine: false)
        _viewModel.log("Card Is Valid: \(_cardView.isValid)")
        
        guard let paymentParams = _cardView.getPaymentMethodParams() else {
            _viewModel.log(_cardView.getErrorMessage(false) + "\n", appendNewLine: true)
            return
        }
        
        _viewModel.createPaymentMethod(params: paymentParams)
    }
    
    @objc func submitForm() {
        _viewModel.log(_formSubmitHeader, prependNewLine: true, appendNewLine: false)
        _viewModel.log("Form Is Valid: \(_formView.isValid)")
        
        guard let paymentParams = _formView.getPaymentMethodParams() else {
            _viewModel.log("Payment Params not valid, returning...\n", appendNewLine: true)
            return
        }
        
        _viewModel.createPaymentMethod(params: paymentParams)
    }
    
    func isBusyChanged(busy: Bool) {
        dispatchToMainThreadIfNecessary {
            self._submitButton.isUserInteractionEnabled = !busy
            self._submitButton.isEnabled = !busy
        }
    }
}

