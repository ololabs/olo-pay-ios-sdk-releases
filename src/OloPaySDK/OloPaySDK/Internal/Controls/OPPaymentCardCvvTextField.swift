// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPCardCvvTextField.swift
//  OloPaySDK
//
//  Created by Justin Anderson on 8/11/23.
//

import Foundation
import UIKit

protocol OPPaymentCardCvvTextFieldDelegate: NSObjectProtocol {
    func fieldChanged(_ cvvTextField: OPPaymentCardCvvTextField)
    func didBeginEditing(_ cvvTextField: OPPaymentCardCvvTextField)
    func didEndEditing(_ cvvTextField: OPPaymentCardCvvTextField)
}

class OPPaymentCardCvvTextField: UITextField, UITextFieldDelegate {
    private static let defaultPadding: CGFloat = 10
    private static let maxCvvLength = 4
    
    private let _defaultGray: UIColor = {
        if #available(iOS 13.0, *) {
            return .systemGray2
        }
        return .lightGray
    }()
    
    private let _defaultBackground: UIColor = {
        if #available(iOS 13.0, *) {
            return .systemBackground
        }
        return .white
    }()
    
    @objc public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    // NOTE: Though it seems weird, this backing variable is necessary
    //       to prevent a crash in the React Native SDK
    private var _inputAccessoryView: UIView? = nil
    @objc open override var inputAccessoryView: UIView? {
        get { _inputAccessoryView }
        set {
            _inputAccessoryView = newValue
            super.inputAccessoryView = newValue
        }
    }
    
    var cvvDelegate: OPPaymentCardCvvTextFieldDelegate?
    
    var cvvFont: UIFont {
        get { font! }
        set { font = newValue }
    }
    
    var placeholderColor: UIColor = .lightGray {
        didSet {
            // Force the placeholder text to update with the new color
            cvvPlaceholder = cvvPlaceholder
        }
    }
    
    var cvvPlaceholder: String {
        get { placeholder ?? "" }
        set {
            attributedPlaceholder = NSAttributedString(string: newValue, attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
        }
    }
    
    var cursorColor: UIColor {
        get { tintColor }
        set { tintColor = newValue }
    }
    
    var borderColor: UIColor? = nil {
        didSet {
            if let borderColor = borderColor {
                layer.borderColor = (borderColor.copy() as! UIColor).cgColor
            } else {
                layer.borderColor = UIColor.clear.cgColor
            }
        }
    }
    
    private var _borderWidth: CGFloat = 1.0
    var borderWidth: CGFloat {
        get { _borderWidth }
        set {
            _borderWidth = newValue
            layer.borderWidth = borderWidth
        }
    }
    
    private var _cornerRadius: CGFloat = 5.0
    var cornerRadius: CGFloat {
        get { _cornerRadius }
        set {
            _cornerRadius = newValue
            layer.cornerRadius = newValue
        }
    }
    
    var contentPadding: UIEdgeInsets = UIEdgeInsets(
        top: defaultPadding,
        left: defaultPadding,
        bottom: defaultPadding,
        right: defaultPadding
    )
    
    var cvvValue: String {
        get { self.text ?? "" }
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return rect.inset(by: contentPadding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return rect.inset(by: contentPadding)
    }
    
    func setup() {
        self.keyboardType = .numberPad
        applyAutofillTraits(for: .cvv)
        font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 18))
        textColor = .black
        cvvPlaceholder = OPStrings.cvvPlaceholder
        placeholderColor = _defaultGray
        
        borderColor = _defaultGray
        borderWidth = _borderWidth
        cornerRadius = _cornerRadius
        backgroundColor = _defaultBackground
        
        addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
        delegate = self
    }
    
    @objc private func textFieldChanged(_ textField: UITextField) {
        cvvDelegate?.fieldChanged(self)
    }
    
    @objc public func textFieldDidBeginEditing(_ textField: UITextField) {
        cvvDelegate?.didBeginEditing(self)
    }
    
    @objc public func textFieldDidEndEditing(_ textField: UITextField) {
        cvvDelegate?.didEndEditing(self)
    }
    
    @objc public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let current = text ?? ""
        guard let swiftRange = Range(range, in: current) else { return false }
        
        if string.isEmpty { return true }
        
        // With a textContentType set, UIKit first inserts a lone space into an empty field before
        // delivering the autofill payload. Stripe's text formatters accept the same handshake.
        if current.isEmpty && range == NSRange(location: 0, length: 0) && string == " " && textContentType != nil {
            return true
        }
        
        let proposed = current.replacingCharacters(in: swiftRange, with: string)
        let digits = Self.asciiDigits(in: proposed)
        let currentDigitCount = Self.asciiDigits(in: current).count
        
        if currentDigitCount >= Self.maxCvvLength && digits.count > currentDigitCount {
            return false
        }
        
        if proposed == digits && proposed.count <= Self.maxCvvLength {
            return true
        }
        
        guard !digits.isEmpty else { return false }
        
        // Autofill and paste payloads can contain non-digits or exceed the max length. Apply the
        // sanitized text ourselves. A programmatic text change doesn't send .editingChanged, so
        // notify directly (textFieldChanged is this field's only .editingChanged target).
        let sanitized = String(digits.prefix(Self.maxCvvLength))
        if sanitized != current {
            text = sanitized
            textFieldChanged(self)
        }
        return false
    }
    
    private static func asciiDigits(in string: String) -> String {
        return string.filter { $0.isASCII && $0.isNumber }
    }
}
