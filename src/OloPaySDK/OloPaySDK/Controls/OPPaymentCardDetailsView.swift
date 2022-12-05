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

/// Protocol to hook into editing events with `OPPaymentCardDetailsView`
@objc public protocol OPPaymentCardDetailsViewDelegate: NSObjectProtocol {
    /// Called when any field changes. This could be used to check `OPPaymentCardDetailsView.isValid` to determine
    /// whether or not enable a button to submit the card details
    /// - Parameters:
    ///     - cardDetails: The card details view that changed
    @objc optional func paymentCardDetailsViewDidChange(_ cardDetails: OPPaymentCardDetailsView)

    /// Called when editing begins in the view as a whole. After receiving this callback, you will also receive a callback for which
    /// specific field in the view began editing.
    /// - Parameters:
    ///     - cardDetails: The card details view that changed
    @objc optional func paymentCardDetailsViewDidBeginEditing(_ cardDetails: OPPaymentCardDetailsView)

    /// Called when editing ends in view as a whole. This callback is always preceded by a callback for which
    /// specific field in the view ended its editing.
    /// - Parameters:
    ///     - cardDetails: The card details view that changed
    @objc optional func paymentCardDetailsViewDidEndEditing(_ cardDetails: OPPaymentCardDetailsView)

    /// Called when editing begins on a specific field
    /// - Parameters:
    ///     - cardDetails: The card details view that changed
    ///     - field: The field that began editing
    @objc optional func paymentCardDetailsViewFieldDidBeginEditing(_ cardDetails: OPPaymentCardDetailsView, field: OPCardField)

    /// Called when editing ends on a specific field
    /// - Parameters:
    ///     - cardDetails: The card details view that changed
    ///     - field: The field that ended editing
    @objc optional func paymentCardDetailsViewFieldDidEndEditing(_ cardDetails: OPPaymentCardDetailsView, field: OPCardField)
}

/// Convenience view for gathering card details from a user.
/// - Important: Card details are intentionally restricted for PCI compliance
@objc public class OPPaymentCardDetailsView : UIView, UIKeyInput, OPPaymentCardDetailsViewInternalDelegate {
    let _cardDetails: OPPaymentCardDetailsInternalView = OPPaymentCardDetailsInternalView()
    let _errorMessage: UILabel = UILabel()
    var _displayErrorMessages = true
    
    var _editedFields: [OPCardField : Bool] = [
        OPCardField.number: false,
        OPCardField.expiration: false,
        OPCardField.cvc: false,
        OPCardField.postalCode: false
    ]

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
        _errorMessage.font = UIFont.systemFont(ofSize: 14)
        _errorMessage.accessibilityIdentifier = "Error Message"
        
        let viewSpacing: CGFloat = 5.0
        let stackView = UIStackView()
        stackView.axis = NSLayoutConstraint.Axis.vertical
        stackView.distribution = UIStackView.Distribution.fill
        stackView.alignment = UIStackView.Alignment.fill
        stackView.spacing = viewSpacing
        
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
    }
        
    /// The font used in each child field. Default is UIFont.systemFont(ofSize:18)
    @objc public var font: UIFont {
        get { _cardDetails.font }
        set {
            _cardDetails.font = newValue
            _errorMessage.font = newValue
        }
    }
    
    /// The font used for error text
    @objc public var errorFont: UIFont {
        get { _errorMessage.font }
        set { _errorMessage.font = newValue }
    }

    /// The text color to be used when entering valid text. Default is .label
    @objc public var textColor: UIColor {
        get { _cardDetails.textColor }
        set { _cardDetails.textColor = newValue }
    }

    /// The text color to be used when the user has entered invalid information, such as an invalid card number. Default is .red
    @objc public var textErrorColor: UIColor {
        get { _cardDetails.textErrorColor }
        set {
            _cardDetails.textErrorColor = newValue
            _errorMessage.textColor = newValue
        }
    }

    /// The text placeholder color used in each child field. This will also set the color of the card placeholder icon. Default is .systemGray2
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

    /// The placeholder for the cvc field. Defaults to “CVC”
    @objc @IBInspectable public var cvcPlaceholder: String? {
        get { _cardDetails.cvcPlaceholder }
        set { _cardDetails.cvcPlaceholder = newValue }
    }

    /// The placeholder for the postal code field. Defaults to “ZIP” for United States or “Postal” for all other country codes
    @objc @IBInspectable public var postalCodePlaceholder: String? {
        get { _cardDetails.postalCodePlaceholder }
        set { _cardDetails.postalCodePlaceholder = newValue }
    }

    /// The cursor color for the field.
    /// This is a proxy for the view's tintColor property, exposed for clarity only
    /// (in other words, calling setCursorColor is identical to calling setTintColor)
    @objc public var cursorColor: UIColor {
        get { _cardDetails.cursorColor }
        set { _cardDetails.cursorColor = newValue }
    }

    /// The border color for the field. Can be nil (in which case no border will be drawn). Default is .systemGray2
    @objc public var borderColor: UIColor? {
        get { _cardDetails.borderColor }
        set { _cardDetails.borderColor = newValue }
    }

    /// The width of the field’s border. Default is 1.0
    @objc public var borderWidth: CGFloat {
        get { _cardDetails.borderWidth }
        set { _cardDetails.borderWidth = newValue }
    }

    /// The corner radius for the field’s border. Default is 5.0
    @objc public var cornerRadius: CGFloat {
        get { _cardDetails.cornerRadius }
        set { _cardDetails.cornerRadius = newValue }
    }

    /// The keyboard appearance for the field. Default is UIKeyboardAppearanceDefault
    @objc public var keyboardAppearance: UIKeyboardAppearance {
        get { _cardDetails.keyboardAppearance }
        set { _cardDetails.keyboardAppearance = newValue }
    }

    /// This behaves identically to setting the inputView for each child text field
    @objc public override var inputView: UIView? {
        get { _cardDetails.inputView }
        set { _cardDetails.inputView = newValue }
    }

    /// This behaves identically to setting the inputAccessoryView for each child text field
    @objc public override var inputAccessoryView: UIView? {
        get { _cardDetails.inputAccessoryView }
        set { _cardDetails.inputAccessoryView = newValue }
    }

    /// The curent brand image displayed in the receiver
    @objc public var brandImage: UIImage? { _cardDetails.brandImage }

    /// Whether or not the form currently contains a valid card number, expiration date, CVC, and postal code (if required)
    @objc dynamic public var isValid: Bool {
        guard cardType != .unknown && cardType != .unsupported else {
            return false
        }
        
        if !postalCodeIsValid {
            return false
        }
        
        return _cardDetails.isValid
    }

    /// Enable/disable selecting or editing the field. Useful when submitting card details to Olo
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
        guard cardType != .unknown && cardType != .unsupported, let cardNumber = _cardDetails.cardNumber else {
            return false
        }

        return STPCardValidator.validationState(forNumber: cardNumber, validatingCardBrand: true) == .valid
    }

    /// Whether or not the expiration field is valid
    @objc public var expirationIsValid: Bool { expirationMonthIsValid && expirationYearIsValid }

    /// Whether or not the expiration month is valid
    @objc public var expirationMonthIsValid: Bool {
        guard let expirationMonth = _cardDetails.formattedExpirationMonth else {
            return false
        }
        
        return STPCardValidator.validationState(forExpirationMonth: expirationMonth) == .valid
    }

    /// Whether or not the expiration year is valid
    @objc public var expirationYearIsValid: Bool {
        guard expirationMonthIsValid, let expirationYear = _cardDetails.formattedExpirationYear else {
            return false
        }
        
        return STPCardValidator.validationState(forExpirationYear: expirationYear, inMonth: _cardDetails.formattedExpirationMonth!) == .valid
    }

    /// Whether or not the CVC is valid
    @objc public var cvcIsValid: Bool {
        guard let cvc = _cardDetails.cvc else {
            return false
        }
        
        return STPCardValidator.validationState(forCVC: cvc, cardBrand: OPCardBrand.convert(from: cardType)) == .valid
    }

    /// Whether or not the card number field is empty
    @objc public var cardNumberIsEmpty: Bool {
        guard let cardNumber = _cardDetails.cardNumber else { return true }
        return cardNumber.isEmpty
    }

    /// Whether or not the postal code is valid. This will return `true` if `postalCodeEntryEnabled` is `false`
    @objc public var postalCodeIsValid: Bool {
        if (!postalCodeEntryEnabled) {
            return true
        }
        
        guard let postalCode = _cardDetails.postalCode else { return false }

        return isValidUsPostalCode(postalCode: postalCode) || isValidCaPostalCode(postalCode: postalCode)
    }
    
    /// Whether or not the expiration field is empty
    @objc public var expirationIsEmpty: Bool { expirationYearIsEmpty && expirationMonthIsEmpty }
    
    /// Whether or not the expiration month is empty
    @objc public var expirationMonthIsEmpty: Bool {
        guard let expirationMonth = _cardDetails.formattedExpirationMonth else { return true }
        return expirationMonth.isEmpty
    }

    /// Whether or not the expiration year is empty
    @objc public var expirationYearIsEmpty: Bool {
        guard let expirationYear = _cardDetails.formattedExpirationYear else { return true }
        return expirationYear.isEmpty
    }

    /// Whether or not the cvc is empty
    @objc public var cvcIsEmpty: Bool {
        guard let cvc = _cardDetails.cvc else { return true }
        return cvc.isEmpty
    }
    
    /// `true` if the postal code is empty, `false` otherwise
    @objc public var postalCodeIsEmpty: Bool {
        guard let postalCode = _cardDetails.postalCode else { return true }
        return postalCode.isEmpty
    }
    
    /// Controls if a postal code entry field will be displayed to the user. Default is YES. If YES, the type of code entry shown is controlled
    /// by the set countryCode value. Some country codes may result in no postal code entry being shown if those countries do not
    /// commonly use postal codes. If NO, no postal code entry will ever be displayed
    @objc public var postalCodeEntryEnabled: Bool {
        get { _cardDetails.postalCodeEntryEnabled }
        set { _cardDetails.postalCodeEntryEnabled = newValue }
    }

    /// The two-letter ISO country code that corresponds to the user’s billing address. If postalCodeEntryEnabled is YES, this controls
    /// which type of entry is allowed. If postalCodeEntryEnabled is NO, this property currently has no effect. If set to nil and postal
    /// code entry is enabled, the country from the user’s current locale will be filled in. Otherwise the specific country code set will be
    /// used. By default this will fetch the user’s current country code from NSLocale
    @objc public var countryCode: String? {
        get { _cardDetails.countryCode }
        set { _cardDetails.countryCode = newValue }
    }

    /// Causes the text field to begin editing. Presents the keyboard
    @objc @discardableResult public override func becomeFirstResponder() -> Bool { _cardDetails.becomeFirstResponder() }

    /// Causes the text field to stop editing. Dismisses the keyboard
    @objc @discardableResult public override func resignFirstResponder() -> Bool { _cardDetails.resignFirstResponder() }

    /// Resets all of the contents of all of the fields. If the field is currently being edited, the number field will become selected
    @objc public func clear() { _cardDetails.clear() }

    /// Use this to customize CVC images displayed in the view for each type of card
    @objc static public var cvcImageHandler: OPCardBrandImageBlock {
        get { OPPaymentCardDetailsInternalView.cvcImageClosure }
        set { OPPaymentCardDetailsInternalView.cvcImageClosure = newValue }
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
    
    /// Use this to customize the error messages that are displayed when `displayGeneratedErrorMessages` is `true`
    @objc static public var errorMessageHandler: OPCardErrorMessageBlock = getErrorMessage
    
    /// Whether or not the error messages should be displayed based on user input. Defaults to true
    @objc public var displayGeneratedErrorMessages: Bool {
        get { _displayErrorMessages }
        set {
            _displayErrorMessages = newValue
            if !_displayErrorMessages {
                _errorMessage.text = ""
            }
        }
    }
    
    /// Use this to clear or set the currently displayed error message. If `displayGeneratedErrorMessages` is set to `true` this will be set and cleared
    /// automatically based on user input. If `false` this can be used to set and clear your own messages
    @objc public var errorMessage: String {
        get { _errorMessage.text ?? "" }
        set { _errorMessage.text = newValue }
    }
    
    /// Default error message handler for getting user facing error messages for this control.
    /// - Parameters:
    ///     - control: The instance of the control to get an error message for
    ///     - field: The field to get an error message for
    /// - Returns: An error message for the given control and field if it's in an invalid state, or an empty string if there is no error
    @objc public static func getErrorMessage(for control: OPPaymentCardDetailsView, with field: OPCardField) -> String {
        var errorMessage = ""
        
        switch field {
        case .number:
            if control.cardNumberIsEmpty {
                errorMessage = OPStrings.emptyCardNumberError
            } else if !control.cardNumberIsValid && control.cardType == .unsupported {
                errorMessage = OPStrings.unsupportedCardError
            } else if !control.cardNumberIsValid {
                errorMessage = OPStrings.invalidCardNumberError
            }
        case .expiration:
            if control.expirationIsEmpty {
                errorMessage = OPStrings.emptyExpirationError
            } else if !control.expirationIsValid {
                errorMessage = OPStrings.invalidExpirationError
            }
        case .cvc:
            if control.cvcIsEmpty {
                errorMessage = OPStrings.emptyCvcError
            } else if !control.cvcIsValid {
                errorMessage = OPStrings.invalidCvcError
            }
        case .postalCode:
            if control.postalCodeEntryEnabled {
                if control.postalCodeIsEmpty {
                    errorMessage = OPStrings.emptyPostalCodeError
                } else if !control.postalCodeIsValid {
                    errorMessage = OPStrings.invalidPostalCodeError
                }
            }
        case .unknown:
            if !control.isValid {
                errorMessage = OPStrings.generalCardError
            }
        }
        
        return errorMessage
    }
    
    /// Check if there is an error message that could be displayed (e.g. in a custom dialog)
    /// - Parameters:
    ///     - ignoreUneditedFieldErrors:    If `true` (default value), only fields that have been edited by the user will be considered. "Edited" means the field
    ///                            has received, and subsequently, lost focus
    /// - Returns: `true` if there is an error message that can be displayed to the user
    @objc public func hasErrorMessage(_ ignoreUneditedFieldErrors: Bool = true) -> Bool {
        return !getErrorMessage(ignoreUneditedFieldErrors).isEmpty
    }

    /// Get the error message that would be displayed if `displayGeneratedErrorMessages` is `true` and `isValid` is `false`
    /// Note that `isValid` having a value of `false` does not necessarily mean there will be an error message (see `ignoreUneditedFieldErrors` param).
    /// Error messages can be customized by providing your own `errorMessageHandler`
    /// - Parameters:
    ///     - ignoreUneditedFieldErrors:    If `true` (default value), only fields that have been edited by the user will be considered. "Edited" means the field
    ///                            has received, and subsequently, lost focus
    /// - Returns: An error message that can be displayed to the user (e.g. in a custom dialog)
    @objc public func getErrorMessage(_ ignoreUneditedFieldErrors: Bool = true) -> String {
        guard !isValid else {
            return ""
        }

        //If unedited fields are not ignored, treat all fieds as edited
        let numberEdited = ignoreUneditedFieldErrors ? _editedFields[OPCardField.number]! : true
        let expirationEdited = ignoreUneditedFieldErrors ? _editedFields[OPCardField.expiration]! : true
        let cvcEdited = ignoreUneditedFieldErrors ? _editedFields[OPCardField.cvc]! : true
        let postalCodeEdited = ignoreUneditedFieldErrors ? _editedFields[OPCardField.postalCode]! : true

        if !cardNumberIsValid && numberEdited {
            return OPPaymentCardDetailsView.errorMessageHandler(self, OPCardField.number)
        } else if !expirationIsValid && expirationEdited {
            return OPPaymentCardDetailsView.errorMessageHandler(self, OPCardField.expiration)
        } else if !cvcIsValid && cvcEdited {
            return OPPaymentCardDetailsView.errorMessageHandler(self, OPCardField.cvc)
        } else if !postalCodeIsValid && postalCodeEdited {
            return OPPaymentCardDetailsView.errorMessageHandler(self, OPCardField.postalCode)
        } else if numberEdited && expirationEdited && cvcEdited && postalCodeEdited {
            return OPPaymentCardDetailsView.errorMessageHandler(self, OPCardField.unknown)
        } else {
            return ""
        }
    }

    /// Returns the rectangle in which the receiver draws its brand image.
    /// - Parameter bounds: The bounding rectangle of the receiver.
    /// - Returns: the rectangle in which the receiver draws its brand image.
    @objc(brandImageRectForBounds:) public func brandImageRect(forBounds bounds: CGRect) -> CGRect { _cardDetails.brandImageRect(forBounds: bounds) }

    /// Returns the rectangle in which the receiver draws the text fields.
    /// - Parameter bounds: The bounding rectangle of the receiver.
    /// - Returns: The rectangle in which the receiver draws the text fields.
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

    /// Delegate for callbacks related to text editing begin and end
    @objc public var cardDetailsDelegate: OPPaymentCardDetailsViewDelegate?

    /// :nodoc:
    @objc public override var isFirstResponder: Bool { _cardDetails.isFirstResponder }

    /// :nodoc:
    @objc public override var canBecomeFirstResponder: Bool { _cardDetails.canBecomeFirstResponder }

    /// :nodoc:
    @objc public override var canResignFirstResponder: Bool { _cardDetails.canResignFirstResponder }

    /// :nodoc:
    @objc public override var intrinsicContentSize: CGSize { _cardDetails.intrinsicContentSize }

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
    
    /// Returns the OPPaymentMethodParams object representing the details in the form.
    /// - throws: OPError if the card details are not valid
    @objc public func getPaymentMethodParams() throws -> OPPaymentMethodParamsProtocol {
        if let error = validateCardDetails() {
            updateErrorMessage(ignoreUneditedFieldErrors: false)
            throw error
        }
        
        return OPPaymentMethodParams(_cardDetails.getPaymentMethodParams())
    }
        
    @objc func paymentCardDetailsViewDidChange(_ cardDetails: OPPaymentCardDetailsInternalView) {
        cardDetailsDelegate?.paymentCardDetailsViewDidChange?(self)
        updateErrorMessage()
    }

    @objc func paymentCardDetailsViewDidBeginEditing(_ cardDetails: OPPaymentCardDetailsInternalView) {
        cardDetailsDelegate?.paymentCardDetailsViewDidBeginEditing?(self)
    }

    @objc func paymentCardDetailsViewDidEndEditing(_ cardDetails: OPPaymentCardDetailsInternalView) {
        cardDetailsDelegate?.paymentCardDetailsViewDidEndEditing?(self)
    }

    @objc func paymentCardDetailsViewFieldDidBeginEditing(_ cardDetails: OPPaymentCardDetailsInternalView, field: OPCardField) {
        cardDetailsDelegate?.paymentCardDetailsViewFieldDidBeginEditing?(self, field: field)
        
        // Tweak to fix postal code error handling
        if (field == OPCardField.postalCode && !postalCodeIsEmpty) {
            updateFieldEditedStatus(field: field)
        }
    }

    @objc func paymentCardDetailsViewFieldDidEndEditing(_ cardDetails: OPPaymentCardDetailsInternalView, field: OPCardField) {
        cardDetailsDelegate?.paymentCardDetailsViewFieldDidEndEditing?(self, field: field)
        updateFieldEditedStatus(field: field)
        updateErrorMessage()
    }
    
    @objc func updateFieldEditedStatus(field: OPCardField) {
        switch field {
        case .postalCode:
            if postalCodeIsEmpty { return }
        case .cvc:
            if cvcIsEmpty { return }
        case .expiration:
            if expirationIsEmpty { return }
        case .number:
            if cardNumberIsEmpty { return }
        default:
            break
        }
            
        _editedFields[field] = true
    }
    
    @objc func updateErrorMessage(ignoreUneditedFieldErrors: Bool = true) {
        guard displayGeneratedErrorMessages else { return }
        errorMessage = getErrorMessage(ignoreUneditedFieldErrors)
    }
    
    /// Runs validation on the card details.
    /// - Returns An `OPError` if validation fails, otherwise `nil`
    @objc public func validateCardDetails() -> OPError? {
        var errorMessage: String? = nil
        var errorType: OPCardErrorType? = nil
        
        if !cardNumberIsValid {
            errorMessage = getUserFacingMessage(with: OPCardField.number)
            errorType = OPCardErrorType.invalidNumber
        } else if !expirationIsValid {
            errorMessage = getUserFacingMessage(with: OPCardField.expiration)
            errorType = expirationMonthIsValid ? OPCardErrorType.invalidExpYear : OPCardErrorType.invalidExpMonth
        } else if !cvcIsValid {
            errorMessage = getUserFacingMessage(with: OPCardField.cvc)
            errorType = OPCardErrorType.invalidCVC
        } else if !postalCodeIsValid {
            errorMessage = getUserFacingMessage(with: OPCardField.postalCode)
            errorType = OPCardErrorType.incorrectZip
        } else if !isValid {
            errorMessage = getUserFacingMessage(with: OPCardField.unknown)
            errorType = OPCardErrorType.unknownCardError
        }
        
        guard let errorM = errorMessage, let errorT = errorType else {
            return nil //No client-side error detected
        }
        
        return OPError(cardErrorType: errorT, description: errorM)
    }
    
    /// Gets a user-facing message for the given card field
    /// - Parameters:
    ///     - field: The field to get an error for
    /// - Returns A user-facing error message for the given field, or an empty string if the field is valid
    @objc public func getUserFacingMessage(with field: OPCardField) -> String {
        // First attempt to get an error message from a handler that can be customized by clients... this allows clients
        // to control the message feel/branding
        var errorMessage = OPPaymentCardDetailsView.errorMessageHandler(self, field)
        
        // If the error message is empty, call our code to ensure we have a valid erorr message
        if errorMessage.isEmpty {
            errorMessage = OPPaymentCardDetailsView.getErrorMessage(for: self, with: field)
        }
        
        return errorMessage
    }
    
    func isValidUsPostalCode(postalCode: String) -> Bool {
        let regEx = #"^\s*[0-9]{5}(-[0-9]{4})?\s*$"#
        return postalCode.range(of: regEx, options: .regularExpression) != nil
    }
    
    func isValidCaPostalCode(postalCode: String) -> Bool {
        let regEx = #"^[ABCEGHJKLMNPRSTVXY][0-9][ABCEGHJKLMNPRSTVWXYZ]\s?[0-9][ABCEGHJKLMNPRSTVWXYZ][0-9]$"#
        let upperPostal = postalCode.uppercased()
        return upperPostal.range(of: regEx, options: .regularExpression) != nil
    }
}
