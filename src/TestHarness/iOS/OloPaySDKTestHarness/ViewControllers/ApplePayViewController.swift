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

    private var _lineItemsStack = UIStackView()
    private var _mainStack: UIStackView!
    
    private let _taxLabel = UILabel()
    private let _tipLabel = UILabel()
    private let _subtotalLabel = UILabel()
    private let _totalLabel = UILabel()
    
    private let _taxValue = UILabel()
    private let _tipValue = UILabel()
    private let _subtotalValue = UILabel()
    private let _totalValue = UILabel()
    
    private let _submitButton = PKPaymentButton(paymentButtonType: .buy, paymentButtonStyle: .black)
    private let _logViewController: LogViewController
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(viewModel: ApplePayViewModel) {
        _viewModel = viewModel
        _logViewController = LogViewController(viewModel: _viewModel.logViewModel)
        
        super.init(nibName: nil, bundle: nil)
        _viewModel.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let positiveViewSpacing: CGFloat = 10.0
        let negativeViewSpacing: CGFloat = -10.0
        
        _lineItemsStack.isHidden = !_viewModel.displayLineItems
        _lineItemsStack.axis = .vertical
        _lineItemsStack.distribution = .fill
        _lineItemsStack.spacing = positiveViewSpacing
        _lineItemsStack.translatesAutoresizingMaskIntoConstraints = false
        _lineItemsStack.layer.borderWidth = 1
        _lineItemsStack.layer.cornerRadius = 15
        _lineItemsStack.layer.borderColor = UIColor.lightGray.cgColor
        _lineItemsStack.isLayoutMarginsRelativeArrangement = true
        _lineItemsStack.layoutMargins = UIEdgeInsets(
            top: positiveViewSpacing,
            left: positiveViewSpacing,
            bottom: positiveViewSpacing, 
            right: positiveViewSpacing
        )
        
        _lineItemsStack.addArrangedSubview(setupLineItemView(title: "Tax:", label: _taxLabel, value: _taxValue))
        _lineItemsStack.addArrangedSubview(setupLineItemView(title: "Tip:", label: _tipLabel, value: _tipValue))
        _lineItemsStack.addArrangedSubview(setupLineItemView(title: "Subtotal:", label: _subtotalLabel, value: _subtotalValue))
        
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = .lightGray
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        _lineItemsStack.addArrangedSubview(separator)
        
        _lineItemsStack.addArrangedSubview(setupLineItemView(title: "Total:", label: _totalLabel, value: _totalValue))
        
        _submitButton.addTarget(self, action: #selector(submit), for: .touchUpInside)
        _submitButton.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        _submitButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        _submitButton.accessibilityIdentifier = UITestingIdentifiers.TestHarness.applePayButton
        
        _mainStack = UIStackView(arrangedSubviews: [_lineItemsStack, _submitButton, _logViewController.view])
        _mainStack.axis = .vertical
        _mainStack.distribution = .fill
        _mainStack.alignment = .fill
        _mainStack.spacing = positiveViewSpacing
        
        view.addSubview(_mainStack)
        
        _mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            _mainStack.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1.0),
            _mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            _mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            _mainStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),

            _lineItemsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: positiveViewSpacing),
            _lineItemsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: negativeViewSpacing),
            
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

    func displayLineItemsChanged() {
        _lineItemsStack.isHidden = !_viewModel.displayLineItems
    }
    
    func lineItemsValueChanged() {
        guard _viewModel.displayLineItems else {
            return
        }
        
        _taxValue.text = "$\(_viewModel.tax)"
        _tipValue.text = "$\(_viewModel.tip)"
        _subtotalValue.text = "$\(_viewModel.subtotal)"
        _totalValue.text = "$\(_viewModel.grandTotal)"
    }
    
    func settingsClicked() {
        self.present(SettingsViewController(for: .digitalWallet), animated: true)
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
    
    private func setupLineItemView(title: String, label: UILabel, value: UILabel) -> UIStackView {
        label.text = title
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        
        value.translatesAutoresizingMaskIntoConstraints = false
        value.textAlignment = .right
        
        let lineItemStackView = UIStackView(arrangedSubviews: [label, value])
        lineItemStackView.axis = .horizontal
        lineItemStackView.distribution = .fill
        lineItemStackView.translatesAutoresizingMaskIntoConstraints = false
        
        return lineItemStackView
    }
}
