// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPPaymentCardDetailsForm.swift
//  OloPaySDK
//
//  Created by Justin Anderson on 7/22/21.
//

import Foundation
import UIKit
import Stripe

/// Defines the interface that should be adopted to receive updates from instances of
/// `OPPaymentCardDetailsForm`
@objc public protocol OPPaymentCardDetailsFormDelegate: NSObjectProtocol {
    /// Called when all of the form view's required inputs are valid or transition away from all being valid.
    /// - Parameters:
///         - form: The form that changed state
///         - isValid: Whether or not the form is in a valid state
    @objc optional func isValidChanged(_ form: OPPaymentCardDetailsForm, _ isValid: Bool)
}

/// Convenience multi-field form for collecting card details from a user
/// - Important: Card details are intentionally restricted for PCI compliance
@objc public class OPPaymentCardDetailsForm : UIView, STPCardFormViewDelegate {
    private var _form: STPCardFormView
    private var _isValid: Bool = false
    
    /// Public initializer for `OPPaymentCardDetailsForm`
    /// - Parameters:
    ///     - style: The visual style to use for this instance
    @objc public init(style: OPCardFormStyle = .standard) {
        _form = STPCardFormView(style: OPCardFormStyle.convert(from: style))
        super.init(frame: CGRect.zero)
        setupViews()
    }
    
    /// :nodoc: 
    @objc public override init(frame: CGRect = CGRect.zero) {
        _form = STPCardFormView(style: .standard)
        super.init(frame: frame)
        setupViews()
    }
    
    /// :nodoc:
    @objc public required init?(coder: NSCoder) {
        _form = STPCardFormView(style: .standard)
        super.init(coder: coder)
        setupViews()
    }
    
    /// The delegate to notify when the card form transitions to or from being valid.
    @objc public var cardDetailsDelegate: OPPaymentCardDetailsFormDelegate?
    
    /// The background color for the form
    @objc public override var backgroundColor: UIColor? {
        get { _form.backgroundColor }
        set { _form.backgroundColor = newValue }
    }
    
    /// The background color that is automatically applied to the input fields when  `isUserInteractionEnabled` is set to `false`
    /// - Note: `OPPaymentCardDetailsForm` uses text colors, most of which are iOS system colors, that are designed to be as
    ///         accessible as possible, so any customization should avoid decreasing contrast between the text and background.
    @objc public var disabledBackgroundColor: UIColor? {
        get { _form.disabledBackgroundColor }
        set { _form.disabledBackgroundColor = newValue }
    }
    
    func setupViews() {
        let stackView = UIStackView()
        stackView.axis = NSLayoutConstraint.Axis.vertical
        stackView.distribution = UIStackView.Distribution.fillProportionally
        stackView.alignment = UIStackView.Alignment.fill

        stackView.addArrangedSubview(_form)
        addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ]

        NSLayoutConstraint.activate(constraints)
        _form.delegate = self
    }
    
    /// Whether or not the form is in a valid state. Use `OPPaymentCardDetailsFormDelegate` to know when this state changes
    @objc public var isValid: Bool { _isValid }
    
    /// :nodoc:
    @objc public override var canResignFirstResponder: Bool { _form.canResignFirstResponder }
    
    /// :nodoc:
    @objc public override func resignFirstResponder() -> Bool { _form.resignFirstResponder() }
    
    /// :nodoc:
    @objc public override var isFirstResponder: Bool { _form.isFirstResponder }
    
    /// :nodoc:
    @objc public override var canBecomeFirstResponder: Bool { _form.canBecomeFirstResponder }
    
    /// :nodoc:
    @objc public override func becomeFirstResponder() -> Bool { _form.canBecomeFirstResponder }
    
    /// :nodoc:
    @objc public override var intrinsicContentSize: CGSize { _form.intrinsicContentSize }

    /// :nodoc:
    @objc public override func layoutSubviews() { _form.layoutSubviews() }
    
    /// :nodoc:
    @objc public override var frame: CGRect {
        get { _form.frame }
        set { _form.frame = newValue }
    }
    
    /// :nodoc:
    @objc override public func updateConstraints() {
        _form.updateConstraints()
        super.updateConstraints()
    }
    
    /// Returns the `OPPaymentMethodParamsProtocol` instance representing the details in the form, if it exists, otherwise null.
    @objc public func getPaymentMethodParams() -> OPPaymentMethodParamsProtocol? {
        guard let cardParams = _form.cardParams else {
            return nil
        }
        return OPPaymentMethodParams(cardParams)
    }
    
    /// :nodoc:
    public func cardFormView(_ form: STPCardFormView, didChangeToStateComplete complete: Bool) {
        _isValid = complete
        cardDetailsDelegate?.isValidChanged?(self, _isValid)
    }
}
