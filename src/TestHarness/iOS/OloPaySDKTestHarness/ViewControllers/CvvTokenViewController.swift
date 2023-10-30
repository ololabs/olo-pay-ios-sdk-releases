// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  CvvTokenViewController.swift
//  OloPaySDKTestHarness
//
//  Created by Justin Anderson on 8/11/23.
//

import Foundation
import UIKit
import OloPaySDK

class CvvTokenViewController : UIViewController, CvvTokenViewModelDelegate, ViewControllerWithSettingsProtocol {
    
    private let _cvvSubmitHeader = "---------- CVV FIELD SUBMISSION ----------"

    let _viewModel: CvvTokenViewModel
    
    var _cvvView = OPPaymentCardCvvView()
    var _submitButton = UIButton()
    var _clearButton = UIButton()
    var _clearFocusButton = UIButton()
    var _logViewController: LogViewController
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(viewModel: CvvTokenViewModel) {
        _viewModel = viewModel
        _logViewController = LogViewController(viewModel: _viewModel.logViewModel)
        super.init(nibName: nil, bundle: nil)
        
        _viewModel.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up keyboard done button for input fields
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(clearFocus))
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        toolbar.items = [doneButton]
        
        _cvvView.inputAccessoryView = toolbar
        _cvvView.cvvDetailsDelegate = _viewModel
        
        _submitButton.setTitle("Submit Cvv", for: .normal)
        _submitButton.backgroundColor = .systemBlue
        _submitButton.setTitleColor(.white, for: .normal)
        _submitButton.setTitleColor(.darkGray, for: .disabled)
        _submitButton.addTarget(self, action: #selector(submit), for: .touchUpInside)
        
        _clearButton.setTitle("Clear Cvv", for: .normal)
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
        
        let positiveViewSpacing: CGFloat = 10.0
        let negativeViewSpacing: CGFloat = -10.0
        
        let buttonStack = UIStackView(arrangedSubviews: [_submitButton, _clearButton, _clearFocusButton])
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.alignment = .fill
        buttonStack.spacing = positiveViewSpacing
        
        let mainStack = UIStackView(arrangedSubviews: [_cvvView, buttonStack, _logViewController.view])
        mainStack.axis = .vertical
        mainStack.distribution = .fill
        mainStack.alignment = .fill
        mainStack.spacing = positiveViewSpacing
        
        view.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            mainStack.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1.0),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            _logViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: positiveViewSpacing),
            _logViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: negativeViewSpacing),
            _logViewController.view.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
            
            _cvvView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: positiveViewSpacing),
            _cvvView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: negativeViewSpacing),
            
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: positiveViewSpacing),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: negativeViewSpacing)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        self.addChild(_logViewController)
        _logViewController.didMove(toParent: self)
    }
    
    @objc func submit() {
        _viewModel.log(_cvvSubmitHeader, prependNewLine: true, appendNewLine: false)
        
        guard let params = _cvvView.getCvvTokenParams() else {
            _viewModel.log("CVV Params not valid")
            return
        }
        
        _viewModel.createToken(params: params)
        
    }
    
    @objc func clear() {
        _cvvView.clear()
    }
    
    @objc func clearFocus() {
        let _ = _cvvView.resignFirstResponder()
    }
    
    func isBusyChanged(busy: Bool) {
        dispatchToMainThreadIfNecessary {
            self._submitButton.isEnabled = !busy
        }
    }
    
    func settingsChanged(settings: TestHarnessSettingsProtocol) {
        loadSettings(settings: settings)
    }
    
    func settingsClicked() {
        let _ = _cvvView.resignFirstResponder()
        self.present(SettingsViewController(), animated: true)
    }
    
    private func loadSettings(settings: TestHarnessSettingsProtocol) {
        _cvvView.displayGeneratedErrorMessages = settings.displayCvvErrors
        
        OPPaymentCardCvvView.errorMessageHandler = settings.customCvvErrorMessages ? _viewModel.customErrorMessageHandler(_:_:) : nil
    }
}
