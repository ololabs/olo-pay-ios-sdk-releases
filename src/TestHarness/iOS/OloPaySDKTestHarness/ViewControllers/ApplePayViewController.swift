// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  ApplePayViewController.swift
//  OloPaySDKTestHarness
//
//  Created by Justin Anderson on 8/11/23.
//

import Foundation
import UIKit
import PassKit
import OloPaySDK

class ApplePayViewController : UIViewController, ApplePayViewModelDelegate, ViewControllerWithSettingsProtocol {
    private let _viewModel: ApplePayViewModel
    
    private let applePaySubmitHeader = "----------- APPLE PAY SUBMISSION -----------"
    
    private let _submitButton = PKPaymentButton(paymentButtonType: .buy, paymentButtonStyle: .black)
    private let _logViewController: LogViewController
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(viewModel: ApplePayViewModel) {
        _viewModel = viewModel
        _logViewController = LogViewController(viewModel: _viewModel.logViewModel)
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _submitButton.addTarget(self, action: #selector(submit), for: .touchUpInside)
        _submitButton.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        _submitButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        _submitButton.accessibilityIdentifier = UITestingIdentifiers.TestHarness.applePayButton
        
        let positiveViewSpacing: CGFloat = 10.0
        let negativeViewSpacing: CGFloat = -10.0
        
        let mainStack = UIStackView(arrangedSubviews: [_submitButton, _logViewController.view])
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

            _submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: positiveViewSpacing),
            _submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: negativeViewSpacing),
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        self.addChild(_logViewController)
        _logViewController.didMove(toParent: self)
    }
    
    func settingsClicked() {
        self.present(SettingsViewController(), animated: true)
    }
    
    func isBusyChanged(busy: Bool) {
        dispatchToMainThreadIfNecessary {
            self._submitButton.isUserInteractionEnabled = !busy
            self._submitButton.isEnabled = !busy
        }
    }
    
    @objc func submit() {
        _viewModel.log(applePaySubmitHeader, prependNewLine: false, appendNewLine: false)
        _viewModel.createPaymentMethod()
    }
}

