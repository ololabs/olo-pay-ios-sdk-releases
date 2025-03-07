// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPPaymentCardDetailsView.swift
//  OloPaySDK
//
//  Created by Justin Anderson on 5/11/21.
//

import Stripe
import Foundation
import UIKit

/// Defines the interface that should be implemented to receive updates from instances of
/// `OPPaymentCardDetailsView`. Each callback method is optional so you only need to implement the ones you need.
/// - Important: There are two versions of each callback method. One version contains a reference to the view and can be used if you are implementing these callbacks in your UI layer. If implementing callbacks in a data layer it is recommended to implement the versions that do not contain a reference to a view.
@objc public protocol OPPaymentCardDetailsViewDelegate: NSObjectProtocol {
    /// Called when any field changes.
    /// - Parameters:
    ///    - cardDetails: The card details view that changed
    @objc optional func paymentCardDetailsViewDidChange(_ cardDetails: OPPaymentCardDetailsView)

    /// Called when any field changes.
    /// - Important: If using Swift, `fieldStates` can be converted to a Swift Dictionary as follows: ```let state = fieldStates as! Dictionary<OPCardField, OPCardFieldStateProtocol>```
    /// - Parameters:
    ///    - fieldStates: A dictionary representing the current state of the view. Keys are of type `OPCardField` and values are of type `OPCardFieldStateProtocol`
    ///    - isValid: A convenience parameter to quickly determine if the view is in a valid state (e.g. all fields in the dictionary have an `isValid` property with a value of `true`)
    @objc optional func paymentCardDetailsViewDidChange(with fieldStates: NSDictionary, isValid: Bool)
    
    /// Called when editing begins in the view as a whole. This will always be followed by a `paymentCardDetailsViewFieldDidBeginEditing(...)` callback.
    /// - Parameters:
    ///    - cardDetails: The card details view that changed
    @objc optional func paymentCardDetailsViewDidBeginEditing(_ cardDetails: OPPaymentCardDetailsView)

    /// Called when editing begins on the view as a whole. This will always be followed by a `paymentCardDetailsViewFieldDidBeginEditing(...)` callback.
    /// - Important: If using Swift, `fieldStates` can be converted to a Swift Dictionary as follows: ```let state = fieldStates as! Dictionary<OPCardField, OPCardFieldStateProtocol>```
    /// - Parameters:
    ///    - fieldStates: A dictionary representing the current state of the view. Keys are of type `OPCardField` and values are of type `OPCardFieldStateProtocol`
    ///    - isValid: A convenience parameter to quickly determine if the view is in a valid state (e.g. all fields in the dictionary have an `isValid` property with a value of `true`)
    @objc optional func paymentCardDetailsViewDidBeginEditing(with fieldStates: NSDictionary, isValid: Bool)
    
    /// Called when editing ends on the view as a whole. This will always be preceded by a `paymentCardDetailsViewFieldDidEndEditing(...)` callback.
    /// - Parameters:
    ///    - cardDetails: The card details view that changed
    @objc optional func paymentCardDetailsViewDidEndEditing(_ cardDetails: OPPaymentCardDetailsView)

    /// Called when editing ends on the view as a whole. This will always be preceded by a `paymentCardDetailsViewFieldDidEndEditing(...)` callback.
    /// - Important: If using Swift, `fieldStates` can be converted to a Swift Dictionary as follows: ```let state = fieldStates as! Dictionary<OPCardField, OPCardFieldStateProtocol>```
    /// - Parameters:
    ///    - fieldStates: A dictionary representing the current state of the view. Keys are of type `OPCardField` and values are of type `OPCardFieldStateProtocol`
    ///    - isValid: A convenience parameter to quickly determine if the view is in a valid state (e.g. all fields in the dictionary have an `isValid` property with a value of `true`
    @objc optional func paymentCardDetailsViewDidEndEditing(with fieldStates: NSDictionary, isValid: Bool)
    
    /// Called when editing begins on a specific field
    /// - Parameters:
    ///    - cardDetails: The card details view that changed
    ///    - field: The field that is being edited
    @objc optional func paymentCardDetailsViewFieldDidBeginEditing(_ cardDetails: OPPaymentCardDetailsView, field: OPCardField)

    /// Called when editing begins on a specific field
    /// - Important: If using Swift, `fieldStates` can be converted to a Swift Dictionary as follows: ```let state = fieldStates as! Dictionary<OPCardField, OPCardFieldStateProtocol>```
    /// - Parameters:
    ///    - fieldStates: A dictionary representing the current state of the view. Keys are of type `OPCardField` and values are of type `OPCardFieldStateProtocol`
    ///    - field: The field that is being edited
    ///    - isValid: A convenience parameter to quickly determine if the view is in a valid state (e.g. all fields in the dictionary have an `isValid` property with a value of `true`
    @objc optional func paymentCardDetailsViewFieldDidBeginEditing(with fieldStates: NSDictionary, field: OPCardField, isValid: Bool)
    
    /// Called when editing ends for a specific field
    /// - Parameters:
    ///    - cardDetails: The card details view that changed
    ///    - field: The field that is no longer being edited
    @objc optional func paymentCardDetailsViewFieldDidEndEditing(_ cardDetails: OPPaymentCardDetailsView, field: OPCardField)
    
    /// Called when editing ends for a specific field
    /// - Important: If using Swift, `fieldStates` can be converted to a Swift Dictionary as follows: ```let state = fieldStates as! Dictionary<OPCardField, OPCardFieldStateProtocol>```
    /// - Parameters:
    ///    - fieldStates: A dictionary representing the current state of the view. Keys are of type `OPCardField` and values are of type `OPCardFieldStateProtocol`
    ///    - field: The field that is being edited
    ///    - isValid: A convenience parameter to quickly determine if the view is in a valid state (e.g. all fields in the dictionary have an `isValid` property with a value of `true`
    @objc optional func paymentCardDetailsViewFieldDidEndEditing(with fieldStates: NSDictionary, field: OPCardField, isValid: Bool)
    
    /// Called whenever the view's `isValid` property changes
    /// - Parameters:
    ///    - cardDetails: The card details view that changed
    @objc optional func paymentCardDetailsViewIsValidChanged(_ cardDetails: OPPaymentCardDetailsView)
    
    /// Called whenever the view's `isValid` property changes
    /// - Important: If using Swift, `fieldStates` can be converted to a Swift Dictionary as follows: ```let state = fieldStates as! Dictionary<OPCardField, OPCardFieldStateProtocol>```
    /// - Parameters:
    ///    - fieldStates: A dictionary representing the current state of the view. Keys are of type `OPCardField` and values are of type `OPCardFieldStateProtocol`
    ///    - isValid: A convenience parameter to quickly determine if the view is in a valid state (e.g. all fields in the dictionary have an `isValid` property with a value of `true`
    @objc optional func paymentCardDetailsViewIsValidChanged(with fieldStates: NSDictionary, isValid: Bool)
}

/// Convenience view for gathering card details from a user.
/// - Important: Card details are intentionally restricted for PCI compliance
@objc public class OPPaymentCardDetailsView : UIView, UIKeyInput, OPPaymentCardDetailsViewInternalDelegate, OPValidStateChangedDelegate {
    let _cardDetails: OPPaymentCardDetailsInternalView = OPPaymentCardDetailsInternalView()
    let _errorMessage: UILabel = UILabel()
    let _viewSpacing: CGFloat = 5.0
    var _displayErrorMessages = true
    var _cardState = OPCardState()
    var _clearFieldsInProgress = false
    var _numberField: UITextField?
    var _expirationField: UITextField?
    var _cvvField: UITextField?
    var _postalCodeField: UITextField?

    /// :nodoc:
    @objc public convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    /// :nodoc:
    @objc public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews(frame: frame)
    }
    
    /// :nodoc:
    @objc public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupViews(frame: CGRect? = nil) {
        _errorMessage.textAlignment = .center
        _errorMessage.textColor = _cardDetails.textErrorColor
        _errorMessage.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 14))
        _errorMessage.accessibilityIdentifier = "Error Message"
        
        let stackView = UIStackView()
        stackView.axis = NSLayoutConstraint.Axis.vertical
        stackView.distribution = UIStackView.Distribution.fill
        stackView.alignment = UIStackView.Alignment.fill
        stackView.spacing = _viewSpacing
        
        stackView.addArrangedSubview(_cardDetails)
        stackView.addArrangedSubview(_errorMessage)
        
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.leftAnchor.constraint(equalTo: self.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: self.rightAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
        
        _cardDetails.cardDetailsDelegate = self
        _cardState.delegate = self
        
        numberPlaceholder = OPStrings.numberPlaceholder
        expirationPlaceholder = OPStrings.expirationPlaceholder
        cvvPlaceholder = OPStrings.cvvPlaceholder
        postalCodePlaceholder = OPStrings.postalCodePlaceholder
        
        // Must be called after setting all placeholders to known values
        setupTextFields()
    }
        
    /// The state of this control as an `NSDictionary`. Keys are of type `OPCardField`.
    /// Values are of type `OPCardFieldStateProtocol`
    /// - Important: The control is valid if all fields have an `isValid` value of `true`
    /// - Important: This property is intended mainly for compatibily with obj-c.  Swift users should use `fieldStates`
    @objc public var fieldStatesObjc: NSDictionary {
        get { fieldStates as NSDictionary }
    }

    /// The state of this control.
    /// - Important: The control is valid if all fields have an `isValid` value of `true`
    public var fieldStates: [OPCardField : OPCardFieldStateProtocol] {
        get { _cardState.fieldStates }
    }
    
    /// The font used in each child field. Default is `UIFont.systemFont(ofSize: 18)`
    @objc public var font: UIFont {
        get { _cardDetails.font }
        set {
            _cardDetails.font = newValue
            _errorMessage.font = newValue
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

    /// The text color used when entering valid text. Default is `.label`
    @objc public var textColor: UIColor {
        get { _cardDetails.textColor }
        set { _cardDetails.textColor = newValue }
    }

    /// The text color used when the user has entered invalid information, such as an invalid card number. Default is `.systemRed`
    @objc public var textErrorColor: UIColor {
        get { _cardDetails.textErrorColor }
        set {
            _cardDetails.textErrorColor = newValue
            _errorMessage.textColor = newValue
        }
    }

    /// The text placeholder color used in each child field. This will also set the color of the card placeholder icon. Default is `.systemGray2`
    @objc public var placeholderColor: UIColor {
        get { _cardDetails.placeholderColor }
        set { _cardDetails.placeholderColor = newValue }
    }

    /// The placeholder for the card number field. Default is “4242424242424242”. If this is set to something that resembles a card number,
    /// it will automatically format it as such (in other words, you don’t need to add spaces to this string)
    @objc @IBInspectable public var numberPlaceholder: String? {
        get { _cardDetails.numberPlaceholder }
        set { _cardDetails.numberPlaceholder = newValue }
    }

    /// The placeholder for the expiration field. Defaults to “MM/YY”
    @objc @IBInspectable public var expirationPlaceholder: String? {
        get { _cardDetails.expirationPlaceholder }
        set { _cardDetails.expirationPlaceholder = newValue }
    }

    /// The placeholder for the cvv field. Defaults to “CVV”
    @objc @IBInspectable public var cvvPlaceholder: String? {
        get { _cardDetails.cvcPlaceholder }
        set { _cardDetails.cvcPlaceholder = newValue }
    }
    
    /// Deprecated: Use `cvvPlaceholder` instead
    @available(*, deprecated, renamed: "cvvPlaceholder")
    @objc @IBInspectable public var cvcPlaceholder: String? {
        get { cvvPlaceholder }
        set { cvvPlaceholder = newValue }
    }

    /// The placeholder for the postal code field. Defaults to "Postal Code"
    @objc @IBInspectable public var postalCodePlaceholder: String? {
        get { _cardDetails.postalCodePlaceholder }
        set { _cardDetails.postalCodePlaceholder = newValue }
    }

    /// The cursor color for the field.
    /// This is a proxy for the view's `tintColor` property, exposed for clarity only
    /// (in other words, setting `cursorColor` is identical to setting `tintColor`)
    @objc public var cursorColor: UIColor {
        get { _cardDetails.cursorColor }
        set { _cardDetails.cursorColor = newValue }
    }

    /// The border color for the field. Can be `nil` (in which case no border will be drawn). Default is `.systemGray2`
    @objc public var borderColor: UIColor? {
        get { _cardDetails.borderColor }
        set { _cardDetails.borderColor = newValue }
    }

    /// The width of the field’s border. Default is `1.0`
    @objc public var borderWidth: CGFloat {
        get { _cardDetails.borderWidth }
        set { _cardDetails.borderWidth = newValue }
    }

    /// The corner radius for the field’s border. Default is `5.0`
    @objc public var cornerRadius: CGFloat {
        get { _cardDetails.cornerRadius }
        set { _cardDetails.cornerRadius = newValue }
    }

    /// The keyboard appearance for the field. Default is `UIKeyboardAppearance.default`
    @objc public var keyboardAppearance: UIKeyboardAppearance {
        get { _cardDetails.keyboardAppearance }
        set { _cardDetails.keyboardAppearance = newValue }
    }

    /// This behaves identically to setting the inputView for each child text field
    @objc public override var inputView: UIView? {
        get { _cardDetails.inputView }
        set { _cardDetails.inputView = newValue }
    }

    /// The custom accessory view to display when this view becomes the first responder
    @objc public override var inputAccessoryView: UIView? {
        get { _cardDetails.inputAccessoryView }
        set { _cardDetails.inputAccessoryView = newValue }
    }

    /// The curent brand image displayed in the receiver
    @objc public var brandImage: UIImage? { _cardDetails.brandImage }

    /// Whether or not all fields are currently in a valid state
    @objc dynamic public var isValid: Bool {
        get { _cardState.isValid }
    }

    /// Enable/disable selecting or editing the field
    @objc public var isEnabled: Bool {
        get { _cardDetails.isEnabled }
        set { _cardDetails.isEnabled = newValue }
    }

    /// The detected brand of the card, based on the user's input
    @objc public var cardType: OPCardBrand {
        OPCardBrand.convert(from: STPCardValidator.brand(forNumber: _cardDetails.cardNumber ?? ""))
    }

    /// Whether or not the card number field is valid
    @objc public var cardNumberIsValid: Bool {
        get { _cardState.cardNumber.isValid }
    }
    
    /// Whether or not the expiration field is valid
    @objc public var expirationIsValid: Bool {
        get { _cardState.expiration.isValid }
    }

    /// Whether or not the CVV is in a valid format
    @objc public var cvvIsValid: Bool {
        get { _cardState.cvv.isValid }
    }
    
    /// Deprecated: Use `cvvIsValid` instead
    @available(*, deprecated, renamed: "cvvIsValid")
    @objc public var cvcIsValid: Bool {
        return cvvIsValid
    }

    /// Whether or not the card number field is empty
    @objc public var cardNumberIsEmpty: Bool {
        get { _cardState.cardNumber.isEmpty }
    }

    /// Whether or not the postal code is in a valid format. This will return `true` if `postalCodeEntryEnabled` is `false`
    @objc public var postalCodeIsValid: Bool {
        get { _cardState.postalCode.isValid }
    }
    
    /// Whether or not the expiration field is empty
    @objc public var expirationIsEmpty: Bool {
        get { _cardState.expiration.isEmpty }
    }
    
    /// Whether or not the cvv is empty
    @objc public var cvvIsEmpty: Bool {
        get { _cardState.cvv.isEmpty }
    }
    
    /// Deprecated: Use `cvvIsEmpty` instead
    @available(*, deprecated, renamed: "cvvIsEmpty")
    @objc public var cvcIsEmpty: Bool {
        return cvvIsEmpty
    }
    
    /// `true` if the postal code is empty, `false` otherwise
    @objc public var postalCodeIsEmpty: Bool {
        get { _cardState.postalCode.isEmpty }
    }
    
    /// Controls if a postal code entry field will be displayed to the user. Default is `true`. If `true`, the type of code entry shown is controlled
    /// by the set `countryCode` value. Some country codes may result in no postal code entry being shown if those countries do not
    /// commonly use postal codes. If `false`, no postal code entry will ever be displayed.
    /// - Important: A postal code is **_**required_** to process a credit card with Olo's Ordering API. If you choose not to use the postal code field associated with this control
    ///              you will need to provide your own mechanism for getting a postal code from the user.
    @objc public var postalCodeEntryEnabled: Bool {
        get { _cardState.postalCodeEnabled }
        set {
            _cardDetails.postalCodeEntryEnabled = newValue
            _cardState.postalCodeEnabled = newValue
        }
    }

    /// The two-letter ISO country code that corresponds to the user’s billing address. If `postalCodeEntryEnabled` is `true`, this controls
    /// which type of entry is allowed. If `postalCodeEntryEnabled` is `false`, this property has no effect. If set to `nil` and postal
    /// code entry is enabled, the country from the user’s current locale will be filled in. Otherwise the specific country code set will be
    /// used. By default this will fetch the user’s current country code from `NSLocale`
    @objc public var countryCode: String? {
        get { _cardDetails.countryCode }
        set { _cardDetails.countryCode = newValue }
    }

    /// Causes the number field to begin editing and presents the keyboard
    /// - Important: This is functionally the same as calling `becomeFirstResponder(at: .number)`
    @objc @discardableResult public override func becomeFirstResponder() -> Bool { self.becomeFirstResponder(at: .number) }
    
    /// Causes the specific text field to begin editing and presents the keyboard
    /// - Parameters:
    ///    - field: Determins which card field to be set as first responder
    @objc @discardableResult public func becomeFirstResponder(at field: OPCardField) -> Bool {
        switch field {
        case .number:
            return _numberField!.becomeFirstResponder()
        case .expiration:
            return _expirationField!.becomeFirstResponder()
        case .cvv:
            return _cvvField!.becomeFirstResponder()
        case .postalCode:
            return _postalCodeField!.becomeFirstResponder()
        case .unknown:
            return false
        }
    }

    /// Causes the text field to stop editing and dismisses the keyboard
    @objc @discardableResult public override func resignFirstResponder() -> Bool { _cardDetails.resignFirstResponder() }

    /// Resets all of the contents of all of the fields. If the field is currently being edited, the number field will become selected
    @objc public func clear() {
        _clearFieldsInProgress = true
        
        let focusedField = _cardState.focusedField
        
        _cardState.reset()
        _cardDetails.clear()
        _cardDetails.resignFirstResponder()
        
        _clearFieldsInProgress = false
        
        if focusedField != nil && focusedField != .number {
            paymentCardDetailsViewFieldDidEndEditing(_cardDetails, field: focusedField!)
        }
        
        _cardDetails.becomeFirstResponder()
        paymentCardDetailsViewDidChange(_cardDetails);
    }

    /// Use this to customize CVV images displayed in the view for each type of card
    @objc static public var cvvImageHandler: OPCardBrandImageBlock {
        get { OPPaymentCardDetailsInternalView.cvvImageClosure }
        set { OPPaymentCardDetailsInternalView.cvvImageClosure = newValue }
    }

    /// Deprecated: Use `cvvImageHandler` instead
    @available(*, deprecated, renamed: "cvvImageHandler")
    @objc static public var cvcImageHandler: OPCardBrandImageBlock {
        get { cvvImageHandler }
        set { cvvImageHandler = newValue }
    }

    /// Use this to customize card images displayed in the view for each type of card
    @objc static public var brandImageHandler: OPCardBrandImageBlock {
        get { OPPaymentCardDetailsInternalView.brandImageClosure }
        set { OPPaymentCardDetailsInternalView.brandImageClosure = newValue }
    }

    /// Use this to customize error images displayed in the view for each type of card
    @objc static public var errorImageHandler: OPCardBrandImageBlock {
        get { OPPaymentCardDetailsInternalView.errorImageClosure }
        set { OPPaymentCardDetailsInternalView.errorImageClosure = newValue }
    }
    
    /// An optional handler for providing custom error messages that are displayed when `displayGeneratedErrorMessages` is `true`. Regardless of whether error messages are displayed or not, error messages can be retrieved by calling
    /// `OPPaymentCardDetailsView.getErrorMessage(...)`
    @objc static public var errorMessageHandler: OPCardErrorMessageBlock? = nil {
        didSet {
            OPCardState.errorMessageHandler = errorMessageHandler
        }
    }
    
    /// Whether or not the error messages should be displayed based on user input. Defaults to `true`
    @objc public var displayGeneratedErrorMessages: Bool {
        get { _displayErrorMessages }
        set {
            _displayErrorMessages = newValue
            updateErrorMessage()
            if !_displayErrorMessages {
                _errorMessage.text = ""
            }
        }
    }
    
    /// Use this to clear or set the currently displayed error message. If `displayGeneratedErrorMessages` is `true` this will be set and cleared
    /// automatically based on user input. If `false` this can be used to set and clear your own messages
    @objc public var errorMessage: String {
        get { _errorMessage.text ?? "" }
        set { _errorMessage.text = newValue }
    }
    
    /// Check if there is an error message that could be displayed (e.g. by the control or in a custom dialog)
    /// - Parameters:
    ///    - ignoreUneditedFieldErrors: If `true` (the default), only fields that have been edited by the user will be considered. In this context, "edited" means the user has entered text and resigned first responder status while not empty. If `false`, all fields will be looked at to determine an error message regardless of whether thay have been "edited"
    /// - Returns: `true` if there is an error message that can be displayed to the user, `false` otherwise
    @objc public func hasErrorMessage(_ ignoreUneditedFieldErrors: Bool = true) -> Bool {
        return _cardState.hasErrorMessage(ignoreUneditedFieldErrors)
    }
    
    /// Get the error message (if any) for this control. Error messages can be customized by providing your own `errorMessageHandler`
    /// - Note: This method functions independently of `displayGeneratedErrorMessages`
    /// - Important: Not being in a valid state does not guarantee an error message will be returned (see the `ignoreUneditedFieldErrors` parameter)
    /// - Parameters:
    ///    - ignoreUneditedFieldErrors: If `true` (the default), only fields that have been edited by the user will be considered. In this context, "edited" means the user has entered text and resigned first responder status while not empty. If `false`, all fields will be looked at to determine an error message regardless of whether thay have been "edited"
    /// - Returns: An error message that can be displayed to the user (e.g. in a custom dialog) or an empty string
    @objc public func getErrorMessage(_ ignoreUneditedFieldErrors: Bool = true) -> String {
        return _cardState.getErrorMessage(ignoreUneditedFieldErrors)
    }

    /// :nodoc:
    @objc(brandImageRectForBounds:) public func brandImageRect(forBounds bounds: CGRect) -> CGRect { _cardDetails.brandImageRect(forBounds: bounds) }

    /// :nodoc:
    @objc(fieldsRectForBounds:) public func fieldsRect(forBounds bounds: CGRect) -> CGRect { _cardDetails.fieldsRect(forBounds: bounds) }

    /// The background color of the field
    @objc public override var backgroundColor: UIColor? {
        get { _cardDetails.backgroundColor }
        set { _cardDetails.backgroundColor = newValue }
    }

    /// The vertical alignment for the field
    @objc public var contentVerticalAlignment: UIControl.ContentVerticalAlignment {
        get { _cardDetails.contentVerticalAlignment }
        set { _cardDetails.contentVerticalAlignment = newValue }
    }

    /// Delegate to receive callbacks about card input events for this view.
    @objc public var cardDetailsDelegate: OPPaymentCardDetailsViewDelegate? = nil

    /// :nodoc:
    @objc public override var isFirstResponder: Bool { _cardDetails.isFirstResponder }

    /// :nodoc:
    @objc public override var canBecomeFirstResponder: Bool { _cardDetails.canBecomeFirstResponder }

    /// :nodoc:
    @objc public override var canResignFirstResponder: Bool { _cardDetails.canResignFirstResponder }

    /// :nodoc:
    @objc public override var intrinsicContentSize: CGSize {
        let newHeight =
            _cardDetails.intrinsicContentSize.height +
            _viewSpacing +
            _errorMessage.intrinsicContentSize.height

        return CGSize(
            width: _cardDetails.intrinsicContentSize.width,
            height: newHeight
        )
    }
    
    /// :nodoc:
    @objc public override func layoutSubviews() { _cardDetails.layoutSubviews() }

    /// :nodoc:
    @objc public var hasText: Bool { _cardDetails.hasText }

    /// :nodoc:
    @objc public func insertText(_ text: String) { _cardDetails.insertText(text) }

    /// :nodoc:
    @objc public func deleteBackward() { _cardDetails.deleteBackward() }

    /// :nodoc:
    @objc override public func updateConstraints() {
        _cardDetails.updateConstraints()
        super.updateConstraints()
    }
    
    /// Returns an `OPPaymentMethodParamsProtocol` instance representing the card details.
    /// - Important: If the CVV is not in a valid state (`isValid` is `false`) then the error message will get updated
    @objc public func getPaymentMethodParams() -> OPPaymentMethodParamsProtocol? {
        guard isValid else {
            updateErrorMessage(ignoreUneditedFieldErrors: false)
            return nil
        }
        
        return OPPaymentMethodParams(_cardDetails.getPaymentMethodParams(), fromSource: OPPaymentMethodSource.singleLineInput)
    }
        
    /// :nodoc:
    func paymentCardDetailsViewDidChange(_ cardDetails: OPPaymentCardDetailsInternalView) {
        guard let focusedField = _cardState.focusedField else {
            return
        }
        
        if focusedField == .number {
            _cardState.onCardNumberChanged(newText: getText(for: .number), brand: cardType)
        } else if focusedField == .expiration {
            _cardState.onExpirationChanged(
                expirationMonth: _cardDetails.formattedExpirationMonth ?? "",
                expirationYear: _cardDetails.formattedExpirationYear ?? "")
        } else if focusedField == .cvv {
            _cardState.onCvvChanged(newText: getText(for: .cvv))
        } else if focusedField == .postalCode {
            _cardState.onPostalCodeChanged(newText: getText(for: .postalCode))
        }
        
        cardDetailsDelegate?.paymentCardDetailsViewDidChange?(self)
        cardDetailsDelegate?.paymentCardDetailsViewDidChange?(with: fieldStatesObjc, isValid: isValid)
        updateErrorMessage()
    }
    
    private func getText(for field: OPCardField) -> String {
        switch (field) {
        case .number:
            return _cardDetails.cardNumber ?? ""
        case .expiration:
            return "\(_cardDetails.formattedExpirationMonth ?? "")\(_cardDetails.formattedExpirationYear ?? "")"
        case .cvv:
            return _cardDetails.cvc ?? ""
        case .postalCode:
            return _cardDetails.postalCode ?? ""
        case .unknown:
            return ""
        }
    }
    
    /// :nodoc:
    func paymentCardDetailsViewDidBeginEditing(_ cardDetails: OPPaymentCardDetailsInternalView) {
        if _clearFieldsInProgress {
            return
        }
        
        cardDetailsDelegate?.paymentCardDetailsViewDidBeginEditing?(self)
        cardDetailsDelegate?.paymentCardDetailsViewDidBeginEditing?(with: fieldStatesObjc, isValid: isValid)
    }

    /// :nodoc:
    func paymentCardDetailsViewDidEndEditing(_ cardDetails: OPPaymentCardDetailsInternalView) {
        if _clearFieldsInProgress {
            return
        }
        
        _cardState.onResignFirstResponder()
        
        cardDetailsDelegate?.paymentCardDetailsViewDidEndEditing?(self)
        cardDetailsDelegate?.paymentCardDetailsViewDidEndEditing?(with: fieldStatesObjc, isValid: isValid)
        
        updateErrorMessage()
    }

    /// :nodoc:
    func paymentCardDetailsViewFieldDidBeginEditing(_ cardDetails: OPPaymentCardDetailsInternalView, field: OPCardField) {
        if _clearFieldsInProgress {
            return
        }
        
        _cardState.onBecomeFirstResponder(field: field)
        
        cardDetailsDelegate?.paymentCardDetailsViewFieldDidBeginEditing?(self, field: field)
        cardDetailsDelegate?.paymentCardDetailsViewFieldDidBeginEditing?(with: fieldStatesObjc, field: field, isValid: isValid)
        updateErrorMessage()
    }

    /// :nodoc:
    func paymentCardDetailsViewFieldDidEndEditing(_ cardDetails: OPPaymentCardDetailsInternalView, field: OPCardField) {
        if _clearFieldsInProgress {
            return
        }
        
        // We need to call this manually because Stripe calls this end editing callback PRIOR to the callbacks indicating
        // which fields are beginning and ending editing states. Without calling this manually, by the time Stripe's view
        // change callback fires, we have a new focused field and we miss the change for the current field. Note that
        // this only happens when the UI auto-advances the cursor to the next field
        paymentCardDetailsViewDidChange(_cardDetails)

        cardDetailsDelegate?.paymentCardDetailsViewFieldDidEndEditing?(self, field: field)
        cardDetailsDelegate?.paymentCardDetailsViewFieldDidEndEditing?(with: fieldStatesObjc, field: field, isValid: isValid)
        updateErrorMessage()
    }
    
    /// :nodoc:
    func validStateChanged(isValid: Bool) {
        cardDetailsDelegate?.paymentCardDetailsViewIsValidChanged?(self)
        cardDetailsDelegate?.paymentCardDetailsViewIsValidChanged?(with: fieldStatesObjc, isValid: isValid)
    }
    
    /// Tells the view to update it's error message, if necessary. This is normally called internally by the view itself
    /// and should not generally need to be called.
    @objc func updateErrorMessage(ignoreUneditedFieldErrors: Bool = true) {
        guard displayGeneratedErrorMessages else { return }
        errorMessage = getErrorMessage(ignoreUneditedFieldErrors)
        invalidateIntrinsicContentSize()
    }
    
    /// :nodoc:
    private func setupTextFields() {
        let allTextFields = OPPaymentCardDetailsInternalView.getAllTextFields(from: _cardDetails)
        
        allTextFields.forEach { field in
            if (field.placeholder == OPStrings.numberPlaceholder) {
                _numberField = field
            } else if (field.placeholder == OPStrings.expirationPlaceholder){
                _expirationField = field
            } else if (field.placeholder == OPStrings.cvvPlaceholder){
                _cvvField = field
            } else if (field.placeholder == OPStrings.postalCodePlaceholder){
                _postalCodeField = field
            }
        }
    }
}
