// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPPaymentCardCvvView.swift
//  OloPaySDK
//
//  Created by Justin Anderson on 8/11/23.
//

import Foundation
import UIKit

/// Defines the interface that should be implemented to receive updates from instances of
/// `OPPaymentCardCvvView`. Each callback method is optional so you only need to implement the ones you need.
/// - Important: There are two versions of each callback method. One version contains a reference to the view and can be used if you are implementing these callbacks in your UI layer. If implementing callbacks in a data layer it is recommended to implement the versions that do not contain a reference to a view.
@objc public protocol OPPaymentCardCvvViewDelegate: NSObjectProtocol {
    /// Called when the field changes due to user input. Useful if the delegate is being used in
    /// the UI layer.
    /// - Parameters:
    ///    - cvvView: The view that changed
    @objc optional func fieldChanged(_ cvvView: OPPaymentCardCvvView)
    
    /// Called when the field changes due to user input. Useful if the delegate is not being
    /// used in the UI layer.
    /// - Parameters:
    ///    - state: The current state of the view that changed
    @objc optional func fieldChanged(with state: OPCardFieldStateProtocol)
    
    /// Called when editing begins in the CVV view. Useful if the delegate is being used in
    /// the UI layer.
    /// - Parameters:
    ///    - cvvView: The view that is being edited
    @objc optional func didBeginEditing(_ cvvView: OPPaymentCardCvvView)
    
    /// Called when editing begins in the CVV view. Useful if the delegate is not being
    /// used in the UI layer.
    /// - Parameters:
    ///    - state: The current state of the view that is beign edited
    @objc optional func didBeginEditing(with state: OPCardFieldStateProtocol)
    
    /// Called when editing ends in the CVV view. Useful if the delegate is being used in
    /// the UI layer.
    ///  - Parameters:
    ///     - cvvView: The view that is no longer being edited
    @objc optional func didEndEditing(_ cvvView: OPPaymentCardCvvView)
    
    /// Called when editing ends in the CVV view. Useful if the delegate is not being
    /// used in the UI layer.
    ///  - Parameters:
    ///     - state: The current state of the view no longer being edited
    @objc optional func didEndEditing(with state: OPCardFieldStateProtocol)
    
    /// Called whenever the the CVV view's `isValid` property changes. Useful if the delegate is being
    /// used in the UI layer
    ///  - Parameters:
    ///     - cvvView: The view that changed
    @objc optional func validStateChanged(_ cvvView: OPPaymentCardCvvView)
    
    /// Called whenever the the CVV view's `isValid` property changes. Useful if the delegate is not being
    /// used in the UI layer.
    ///  - Parameters:
    ///     - state: The current state of the view that changed
    @objc optional func validStateChanged(with state: OPCardFieldStateProtocol)
}

/// Convenience view for gathering CVV details from a user
/// - Important: CVV details are intentionally restricted for PCI compliance
@objc public class OPPaymentCardCvvView : UIView, UIKeyInput, OPPaymentCardCvvTextFieldDelegate, OPValidStateChangedDelegate {
    
    private let _cvvDetails = OPPaymentCardCvvTextField()
    private let _errorMessage = UILabel()
    private let _cvvState = OPCvvState()
    private let _viewSpacing: CGFloat = 5.0
    
    private var _defaultErrorTextColor: UIColor = {
        if #available(iOS 13.0, *) {
            return .systemRed
        }
        return .red
    }()
    
    /// :nodoc:
    @objc public convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    /// :nodoc:
    @objc public override init(frame: CGRect){
        super.init(frame: frame)
        setupViews(frame)
    }
    
    /// :nodoc:
    @objc public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupViews(_ frame: CGRect? = nil) {
        _cvvState.delegate = self
        _cvvDetails.cvvDelegate = self
        
        _errorMessage.textAlignment = .center
        _errorMessage.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 14))
        _errorMessage.textColor = _defaultErrorTextColor
        _errorMessage.accessibilityIdentifier = "Error Message"
        _errorMessage.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        errorTextColor = _defaultErrorTextColor
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = _viewSpacing
        
        stackView.addArrangedSubview(_cvvDetails)
        stackView.addArrangedSubview(_errorMessage)
        
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.leftAnchor.constraint(equalTo: self.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: self.rightAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            _cvvDetails.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 0),
            _cvvDetails.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 0),
            
            _errorMessage.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 0),
            _errorMessage.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 0),
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    /// An optional handler for providing custom error messages that are displayed when `displayGeneratedErrorMessages` is `true`. Regardless of whether error messages are displayed or not, error messages can be retrieved by calling
    /// `OPPaymentCardCvvView.getErrorMessage(...)`
    @objc static public var errorMessageHandler: OPCvvErrorMessageBlock? = nil {
        didSet {
            OPCvvState.errorMessageHandler = errorMessageHandler
        }
    }
    
    /// Delegate for callbacks related to text editing in this view
    @objc public var cvvDetailsDelegate: OPPaymentCardCvvViewDelegate?
    
    /// Provides a snapshot of the current state of this view
    @objc public var fieldState: OPCardFieldStateProtocol {
        get { _cvvState._fieldState }
    }
    
    /// Whether or not error messages should be displayed based on user input. Defaults to `true`
    @objc public var displayGeneratedErrorMessages: Bool = true {
        didSet {
            if !displayGeneratedErrorMessages {
                _errorMessage.text = ""
            } else {
                updateErrorMessage()
            }
        }
    }
    
    /// Use this to clear or set the currently displayed error message. If `displayGeneratedErrorMessages` is `true` then
    /// this will be set and cleared automatically based on user input. If `false` this can be used to set and clear your own error
    /// messages
    @objc public var errorMessage: String {
        get { _errorMessage.text ?? "" }
        set { _errorMessage.text = newValue }
    }
    
    /// The keyboard appearance for the field. Default is `UIKeyboardAppearance.default`
    @objc public var keyboardAppearance: UIKeyboardAppearance {
        get { _cvvDetails.keyboardAppearance }
        set { _cvvDetails.keyboardAppearance = newValue }
    }
    
    /// The font used in the CVV field. Default is `UIFont.systemFont(ofSize: 18)`
    @objc public var cvvFont: UIFont {
        get { _cvvDetails.cvvFont }
        set { _cvvDetails.cvvFont = newValue }
    }
    
    /// The text color used when entering valid text. Default is `.label`
    @objc public var cvvTextColor: UIColor = .label {
        didSet {
            updateErrorMessage()
        }
    }
    
    
    /// The font used for error text. Default is `UIFont.systemFont(ofSize: 14)`
    @objc public var errorFont: UIFont {
        get { _errorMessage.font }
        set { _errorMessage.font = newValue }
    }
    
    /// The alignment of the built in error message, default is `.center`
    @objc public var errorTextAlignment: NSTextAlignment {
        get { _errorMessage.textAlignment }
        set { _errorMessage.textAlignment = newValue }
    }
    
    /// The text color used when the user has entered invalid information, such as an incomplete CVV. Default is `.systemRed`
    @objc public var errorTextColor: UIColor = .red {
        didSet {
            _errorMessage.textColor = errorTextColor
        }
    }
    
    /// The text  color used for placeholder text. Default is `.systemGray2`
    @objc public var placeholderColor: UIColor {
        get { _cvvDetails.placeholderColor }
        set { _cvvDetails.placeholderColor = newValue }
    }
    
    /// The text used as a placeholder when the user has not entered any text. Default is `CVV`
    @objc public var placeholderText: String {
        get { _cvvDetails.cvvPlaceholder }
        set { _cvvDetails.cvvPlaceholder = newValue }
    }
    
    /// The cursor color for the field.
    /// This is a proxy for the view's tintColor property, exposed for clarity only
    /// (in other words, setting `cursorColor` is identical to setting `tintColor`)
    @objc public var cursorColor: UIColor {
        get { _cvvDetails.cursorColor }
        set { _cvvDetails.cursorColor = newValue }
    }
    
    /// The border color for the field. Can be `nil` (in which case no border will be drawn). Default is `.systemGray2`
    @objc public var borderColor: UIColor? {
        get { _cvvDetails.borderColor }
        set { _cvvDetails.borderColor = newValue }
    }
    
    /// The width of the field’s border. Default is `1.0`
    @objc public var borderWidth: CGFloat {
        get { _cvvDetails.borderWidth }
        set { _cvvDetails.borderWidth = newValue }
    }
    
    /// The corner radius for the field’s border. Default is `5.0`
    @objc public var cornerRadius: CGFloat {
        get { _cvvDetails.cornerRadius }
        set { _cvvDetails.cornerRadius = newValue }
    }
    
    /// The padding between the border of the CVV input field and the text. Default is `10` on all sides
    @objc public var contentPadding: UIEdgeInsets {
        get { _cvvDetails.contentPadding }
        set { _cvvDetails.contentPadding = newValue }
    }
    
    /// The alignment of the text within the view
    @objc public var textAlignment: NSTextAlignment {
        get { _cvvDetails.textAlignment }
        set { _cvvDetails.textAlignment = newValue}
    }
    
    /// Whether or not the input field is empty
    @objc public var hasText: Bool { _cvvDetails.hasText }
    
    /// Whether or not the input field contains a valid CVV format
    @objc public var isValid: Bool { _cvvState.isValid }
    
    /// The background color for the CVV input field
    @objc public override var backgroundColor: UIColor? {
        get { _cvvDetails.backgroundColor }
        set { _cvvDetails.backgroundColor = newValue }
    }
    
    /// The custom accessory view to display when this view becomes the first responder
    @objc public override var inputAccessoryView: UIView? {
        get { _cvvDetails.inputAccessoryView }
        set { _cvvDetails.inputAccessoryView = newValue }
    }
    
    /// Enable/disable selecting or editing the field
    @objc public var isEnabled: Bool {
        get { _cvvDetails.isEnabled }
        set { _cvvDetails.isEnabled = newValue }
    }
    
    /// :nodoc:
    @objc public override var isFirstResponder: Bool { _cvvDetails.isFirstResponder }

    /// :nodoc:
    @objc public override var canBecomeFirstResponder: Bool { _cvvDetails.canBecomeFirstResponder }

    /// :nodoc:
    @objc public override var canResignFirstResponder: Bool { _cvvDetails.canResignFirstResponder }
    
    /// :nodoc:
    @objc public override var intrinsicContentSize: CGSize {
        let newHeight =
            _cvvDetails.intrinsicContentSize.height +
            _viewSpacing +
            _errorMessage.intrinsicContentSize.height

        return CGSize(
            width: _cvvDetails.intrinsicContentSize.width,
            height: newHeight
        )
    }

    /// :nodoc:
    public func insertText(_ text: String) { _cvvDetails.insertText(text) }
    
    /// :nodoc:
    public func deleteBackward() { _cvvDetails.deleteBackward() }
    
    /// :nodoc:
    @objc public override func layoutSubviews() { _cvvDetails.layoutSubviews() }
    
    /// Causes the text field to begin editing and presents the keyboard
    @objc override public func becomeFirstResponder() -> Bool {
        _cvvDetails.becomeFirstResponder()
    }
    
    /// Causes the text field to stop editing and dismisses the keyboard
    @objc override public func resignFirstResponder() -> Bool {
        _cvvDetails.resignFirstResponder()
    }
    
    /// Clears the contents of the CVV field
    @objc public func clear() {
        let responderState = _cvvState.isFirstResponder
        _cvvState.reset()
        _cvvState.onFirstResponderStateChanged(responderState)
        _cvvDetails.text = ""
        
        fieldChanged(_cvvDetails)
    }
    
    /// Returns an `OPCvvTokenParamsProtocol` instance representing the CVV entered by the user, or `nil` if the
    /// CVV field is not in a valid state (`isValid` is `false`)
    /// - Important: If the CVV is not in a valid state then the error message will get updated
    @objc public func getCvvTokenParams() -> OPCvvTokenParamsProtocol? {
        _cvvState.editingCompleted()
        updateErrorMessage(ignoreUneditedFieldErrors: false)
        
        guard _cvvState.isValid else {
            return nil
        }
        
        return OPCvvTokenParams(_cvvDetails.cvvValue)
    }
    
    /// Get the error message (if any) for this control. Error messages can be customized by providing your own `errorMessageHandler`
    /// - Note: This method functions independently of `displayGeneratedErrorMessages`
    /// - Important: Not being in a valid state does not guarantee an error message will be returned (see the `ignoreUneditedFieldErrors` parameter)
    /// - Parameters:
    ///   - ignoreUneditedFieldErrors: If `true` (the default) an error message will only be returned if the field has been "edited". In this context, "edited" means the field has become the first responder, had text entered, and stopped being the first responder. If `false` an error message will be returned without regard to whether the field has been "edited" or not.
    /// - Returns: An error message that can be displayed to the user (e.g. in a custom dialog) or an empty string
    @objc public func getErrorMessage(ignoreUneditedFieldErrors: Bool = true) -> String {
        return _cvvState.getErrorMessage(ignoreUneditedFieldErrors)
    }
    
    /// Whether or not there is an error message that could be displayed (e.g. by the control or in a custom dialog)
    /// - Parameters:
    ///    - ignoreUneditedFieldErrors: If `true` (the default) an error message will only be returned if the field has been "edited". In this context, "edited" means the field has become the first responder, had text entered, and stopped being the first responder. If `false` an error message will be returned without regard to whether the field has been "edited" or not.
    /// - Returns: `true` if there is an error message that can be displayed to the user, `false` otherwise
    @objc public func hasErrorMessage(ignoreUneditedFieldErrors: Bool = true) -> Bool {
        return _cvvState.hasErrorMessage(ignoreUneditedFieldErrors)
    }
    
    @objc func updateErrorMessage(ignoreUneditedFieldErrors: Bool = true) {
        let errorText = _cvvState.getErrorMessage(ignoreUneditedFieldErrors)
        _cvvDetails.textColor = errorText.isEmpty ? cvvTextColor : errorTextColor
        
        guard displayGeneratedErrorMessages else {
            return
        }
        
        errorMessage = errorText
        
        invalidateIntrinsicContentSize()
    }
    
    /// :nodoc:
    func fieldChanged(_ cvvTextField: OPPaymentCardCvvTextField) {
        _cvvState.onInputChanged(_cvvDetails.cvvValue)
        updateErrorMessage()
        cvvDetailsDelegate?.fieldChanged?(with: fieldState)
        cvvDetailsDelegate?.fieldChanged?(self)
    }
    
    /// :nodoc:
    func didBeginEditing(_ cvvTextField: OPPaymentCardCvvTextField) {
        _cvvState.onFirstResponderStateChanged(true)
        updateErrorMessage()
        cvvDetailsDelegate?.didBeginEditing?(with: fieldState)
        cvvDetailsDelegate?.didBeginEditing?(self)
        
    }
    
    /// :nodoc:
    func didEndEditing(_ cvvTextField: OPPaymentCardCvvTextField) {
        _cvvState.onFirstResponderStateChanged(false)
        updateErrorMessage()
        cvvDetailsDelegate?.didEndEditing?(with: fieldState)
        cvvDetailsDelegate?.didEndEditing?(self)
    }
    
    /// :nodoc:
    func validStateChanged(isValid: Bool) {
        cvvDetailsDelegate?.validStateChanged?(with: fieldState)
        cvvDetailsDelegate?.validStateChanged?(self)
    }
}
