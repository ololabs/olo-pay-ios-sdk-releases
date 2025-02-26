// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPApplePayLauncher.swift
//  OloPaySDK
//
//  Created by Justin Anderson on 6/16/21.
//
import Foundation
import Stripe
import PassKit

/// Protocol to hook into important events in the ApplePay flow
///
/// __Required:__ Implement `paymentMethodCreated` to get payment method details that need to be submitted to Olo's Ordering API when submitting a basket with OloPay
///
/// __Optional:__ Implement `applePayDismissed` to know when the ApplePay sheet is dismissed
@objc public protocol OPApplePayLauncherDelegate: NSObjectProtocol {
    /// Called after the customer has authorized ApplePay and a payment method has been created.  Implement this method to pass the payment method ID to Olo's Ordering API
    /// when submitting a basket. If the API call returns an error, return that error so the ApplePay payment sheet can be dismissed appropriately.
    ///
    /// - Warning: This method should complete as quickly as possible. If it takes too long, Apple will force a timeout and display an error on the payment sheet.
    ///            The timeout window is about 30 seconds. If a timeout occurs, then `OPApplePayLauncherDelegate.applePayDismissed(...)` will
    ///            be called with a status of `OPApplePayStatus.timeout` prior to this method finishing.
    ///
    /// - Parameters:
    ///    - launcher: The apple pay launcher instance that caused this callback to be called
    ///    - paymentMethod: The `OPPaymentMethod` that represents the customer's Apple Pay payment method.
    /// - Returns: `nil` if basket submission was successful, or an Error from Olo's Ordering API if submission was unsuccessful
    @objc func paymentMethodCreated(from launcher: OPApplePayLauncherProtocol, with paymentMethod: OPPaymentMethodProtocol) -> NSError?
    
    /// Called after the Apple Pay sheet is dismissed with the result of the payment.
    /// Your implementation could stop a spinner and display a receipt view or error to the customer, for example.
    /// - Parameters:
    ///   - launcher: The apple pay launcher instance that caused this callback to be called
    ///   - status: The status of the payment. If the status is `OPApplePayStatus.timeout` that means `OPApplePayLauncherDelegate.paymentMethodCreated(...)` did not
    ///             complete fast enough and Apple forced a timeout status of the Apple Pay sheet
    ///   - error: The error that occurred, if any. This will generally be `OPError`. If the error has an `errorType` of `cardError` it will also contain a user-friendly message
    ///            that can be used to help the user understand why the payment couldn't be completed.
    @objc optional func applePayDismissed(from launcher: OPApplePayLauncherProtocol, with status: OPApplePayStatus, error: Error?)
}

/// Protocol for mocking/testing purposes. See `OPApplePayLauncher` for documentation
@objc public protocol OPApplePayLauncherProtocol : NSObjectProtocol {
    /// See `OPApplePayLauncher.basketId` for documentation
    @objc var basketId: String? { get set }
    
    /// See `OPApplePayLauncher.configuration` for documentation
    @objc var configuration: OPApplePayConfiguration? { get set }
    
    /// See `OPApplePayLauncher.delegate` for documentation
    @objc var delegate: OPApplePayLauncherDelegate? { get set }
    
    /// See `OPApplePayLauncher.present(...)` for documentation
    @objc func present(for amount: NSDecimalNumber, completion: OPVoidBlock?) throws
    
    /// See `OPApplePayLauncher.present(...)` for documentation
    @objc func present(for amount: NSDecimalNumber, with lineItems: [PKPaymentSummaryItem]?, validateLineItems: Bool, completion: OPVoidBlock?) throws

    /// See `OPApplePayLauncher.canMakePayments()` for documentation
    @objc static func canMakePayments() -> Bool
}

/// A helper class that implements and simplifies ApplePay.
///
/// Use of this class looks like this:
/// 1. Create an instance of this class
/// 2. Create instances of `OPApplePayConfiguration` and `OPApplePayLauncherDelegate` and update the `configuration` and `delegate` properties of this class
/// 3. Create a button for ApplePay and connect it to a click handler
/// 4. Enable/Disable or Hide/Show the ApplePay button by calling `OPApplePayLauncher.canMakePayments()`
/// 5. In the click handler, call `OPApplePayLauncher.present()` to present the Apple Pay sheet and begin the payment process
/// 6. Implement `OPApplePayLauncherDelegate.paymentMethodCreated(...)` to submit the basket to Olo's Ordering API
/// 7. Optionally implement `OPApplePayLauncherDelegate.applePayDismissed(...)` to handle success and error states when the ApplePay sheet is dimissed
///
/// - Warning: OPApplePayLauncher needs to be created as a class member variable rather than a variable with function scope or else it can become
///            `nil` while the ApplePay sheet is presented and callback methods won't get called
///
/// __Example Implementation__
/// ```
/// class ViewController: UIViewController, OPApplePayLauncherDelegate {
///     // This needs to be a class member variable or it can go out of
///     // scope during the ApplePay flow and become nil, preventing callbacks
///     // from executing
///     var _applePayLauncher: OPApplePayLauncherProtocol
///
///     required init() {
///         _applePayLauncher = OPApplePayLauncher()
///         super.init()
///
///         _applePayLauncher.delegate = self
///         _applePayLauncher.configuration = OPApplePayConfiguration(
///             merchantId: "merchant.com.your.applepay.id",
///             companyLabel: "Your Company Name"
///         )
///     }
///
///     // Called when user taps on ApplePay button to begin ApplePay flow
///     func submitApplePay() {
///         // To allow mocking this check, it could instead be called like this:
///         // type(of: _applePayLauncher).canMakePayments()
///         guard OPApplePayLauncher.canMakePayments() else {
///             return
///         }
///
///         do {
///             let amount: NSDecimalNumber = 1.23
///             try _applePayLauncher?.present(for: amount) {
///                 // Optional logic for when the ApplePay flow is displayed
///             }
///         }
///         catch {
///             // Handle error conditions. See docs for `OPApplePayLauncher.present()` for more information
///         }
///     }
///
///     func paymentMethodCreated(from launcher: OPApplePayLauncherProtocol, with paymentMethod: OPPaymentMethod) -> NSError? {
///         // Use the payment method to submit the basket to Olo's Ordering API (the basket id can be retrieved with `launcher.basketId`
///         // If the API returns an error, return that error. If the API call is successful, return nil
///     }
///
///     func applePayDismissed(from launcher: OPApplePayLauncherProtocol, with status: OPPaymentStatus, error: Error?) {
///         // This is called after the payment sheet has been dismissed
///         // Use the status and error parameters to determine if payment was successful
///     }
/// }
/// ```
@available(iOSApplicationExtension, unavailable)
@available(macCatalystApplicationExtension, unavailable)
@objc public class OPApplePayLauncher : NSObject, PKPaymentAuthorizationControllerDelegate, OPApplePayLauncherProtocol {
    private var _applePayLauncherAssociatedObjectKey = 0
    private var _authController: PKPaymentAuthorizationController?
    private var _configuration: OPApplePayConfiguration?
    private var _delegate: OPApplePayLauncherDelegate?
    private var _error: Error?
    private var _paymentState = ApplePayState.notStarted
    private var _presentationWindow: UIWindow?
    
    static internal var supportedCardNetworks: [PKPaymentNetwork] {
        get { [.visa, .amex, .masterCard, .discover] }
    }
    
    /// Whether or not this device can make Apple Pay payments via a  supported card network
    /// Supported ApplePay card networks are: American Express, Visa, Mastercard, Discover
    ///
    /// - Important: While this should be used in determining if an Apple Pay button can be displayed, it should not be the **_only_** determining factor. It is also
    ///              important to determine whether a restaurant/vendor supports Apple Pay as a payment method, which can be determined using the Olo Ordering API.
    ///
    /// - Returns: `true` if the device is currently able to make Apple Pay payments via one
    /// of the supported networks, or `false` if not
    static public func canMakePayments() -> Bool {
        return PKPaymentAuthorizationController.canMakePayments(
            usingNetworks: supportedCardNetworks
        )
    }
    
    /// Initializes this class.
    /// - Parameters:
    ///   - configuration:  Configuration parameters for Apple Pay
    ///   - delegate:       The delegate.
    /// - Returns:          An `OPApplePayLauncher` instance
    @objc public init(
        configuration: OPApplePayConfiguration? = nil,
        delegate: OPApplePayLauncherDelegate? = nil
    ) {
        _configuration = configuration
        _delegate = delegate
        super.init()
    }
    
    /// Basket ID convenience property for being able to submit a basket in `OPApplePayLauncherDelegate.paymentMethodCreated(...)`
    @objc public var basketId: String? = nil
    
    /// Configuration parameters for processing Apple Pay payments
    @objc public var configuration: OPApplePayConfiguration? {
        get { _configuration }
        set { _configuration = newValue }
    }
    
    /// Delegate to handle callbacks during the Apple Pay flow
    @objc public var delegate: OPApplePayLauncherDelegate? {
        get { _delegate }
        set { _delegate = newValue }
    }
    
    /// Presents the Apple Pay sheet
    ///
    /// - Parameters:
    ///   - for:  The amount to be displayed on the Apple Pay sheet
    ///   - completion: Called after the Apple Pay sheet is visible to the user
    ///  
    /// - Throws: `OPApplePayLauncherError.configurationNotSet`, `OPApplePayLauncherError.delegateNotSet`,
    ///           `OPApplePayLauncherError.emptyMerchantId`, `OPApplePayLauncherError.emptyCompanyLabel`,
    ///           `OPApplePayLauncherError.invalidCountryCode`, `OPApplePayLauncherError.applePayNotSupported`,
    ///           `OPApplePayLauncherError.lineItemTotalMismatchError`
    @objc public func present(for amount: NSDecimalNumber, completion: OPVoidBlock? = nil) throws {
        try self.present(for: amount, with: nil, validateLineItems: true, completion: completion)
    }

    /// Presents the Apple Pay sheet
    ///
    /// - Parameters:
    ///   - for:  The amount to be displayed on the Apple Pay sheet
    ///   - with: A list of line items to be displayed in the Apple Pay sheet. If line items are not needed, this property must be nil and line items will not be displayed
    ///   - validateLineItems: If `true`, throws `OPApplePayLauncherError.lineItemTotalMismatchError`
    ///                        if the sum of the line items does not equal the total amount passed in. 
    ///                        Default is `true`
    ///   - completion: Called after the Apple Pay sheet is visible to the user
    ///   
    /// - Throws: `OPApplePayLauncherError.configurationNotSet`, `OPApplePayLauncherError.delegateNotSet`,
    ///           `OPApplePayLauncherError.emptyMerchantId`, `OPApplePayLauncherError.emptyCompanyLabel`,
    ///           `OPApplePayLauncherError.invalidCountryCode`, `OPApplePayLauncherError.applePayNotSupported`,
    ///           `OPApplePayLauncherError.lineItemTotalMismatchError`
    @objc public func present(
        for amount: NSDecimalNumber,
        with lineItems: [PKPaymentSummaryItem]?,
        validateLineItems: Bool = true,
        completion: OPVoidBlock? = nil
    ) throws {
        if (!OPApplePayLauncher.canMakePayments()) {
            throw OPApplePayLauncherError.applePayNotSupported
        }
        
        guard let config = _configuration else {
            throw OPApplePayLauncherError.configurationNotSet
        }
        
        guard _delegate != nil else {
            throw OPApplePayLauncherError.delegateNotSet
        }

        guard !config.merchantId.isEmpty else {
            throw OPApplePayLauncherError.emptyMerchantId
        }

        guard !config.companyLabel.isEmpty else {
            throw OPApplePayLauncherError.emptyCompanyLabel
        }
        
        guard config.countryCode.count == OPApplePayConfiguration.validCountryCodeLength else {
            throw OPApplePayLauncherError.invalidCountryCode
        }

        if validateLineItems && lineItems != nil {
            let lineItemsTotal = lineItems?.reduce(0) { $0 + ($1.amount as Decimal)}
            
            guard amount as Decimal == lineItemsTotal else {
                throw OPApplePayLauncherError.lineItemTotalMismatchError
            }
        }
        
        dispatchToMainThreadIfNecessary {
            let window = UIApplication.shared.windows.first { $0.isKeyWindow }
            self.present(from: window, for: amount, with: lineItems, completion: completion)
        }
    }
    
    private func present(
        from window: UIWindow?, 
        for amount: NSDecimalNumber, 
        with lineItems: [PKPaymentSummaryItem]?, 
        completion: OPVoidBlock? = nil
    ) {
        _presentationWindow = window
        _paymentState = .pending
        
        let paymentRequest = createPaymentRequest(with: _configuration!, for: amount, with: lineItems)
        
        _authController = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
        _authController!.delegate = self
        
        // This instance must remain alive until the Apple Pay sheet is dismissed; otherwise, the app will be effectively frozen.
        objc_setAssociatedObject(
            _authController!, 
            UnsafeRawPointer(&_applePayLauncherAssociatedObjectKey),
            self,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
        
        _authController!.present { (presented) in
            dispatchToMainThreadIfNecessary {
                completion?()
            }
        }
    }
    
    public func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didAuthorizePayment payment: PKPayment,
        handler completion: @escaping (PKPaymentAuthorizationResult) -> Void
    ) {
        _paymentState = .pendingPaymentProcessing
        
        let metadata = OPMetadataGenerator(
            applePayMerchantId: self.configuration?.merchantId,
            applePayCompanyLabel: self.configuration?.companyLabel
        ).generate()
        
        let client = STPAPIClient.shared
        client.createPaymentMethod(with: payment, metadata: metadata) { paymentMethod, paymentMethodError in
            if let stripePaymentMethod = paymentMethod, paymentMethodError == nil, self._authController != nil {
                let opPaymentMethod = OPPaymentMethod(paymentMethod: stripePaymentMethod, pkPayment: payment, applePayConfig: self._configuration)
                
                DispatchQueue.global(qos: .userInitiated).async {
                    let error = self._delegate?.paymentMethodCreated(from: self, with: opPaymentMethod)
                    
                    guard self._paymentState != .timeout else {
                        return
                    }
                    
                    self._error = error
                    if error == nil {
                        self._paymentState = .success
                        let result = PKPaymentAuthorizationResult(status: .success, errors: nil)
                        completion(result)
                    } else {
                        self._paymentState = .error
                        let errors = [error].compactMap({ $0 })
                        let result = PKPaymentAuthorizationResult(status: .failure, errors: errors)
                        completion(result)
                    }
                }
                
            } else {
                self._error = paymentMethodError
                let errors = [paymentMethodError].compactMap({ $0 })
                let result = PKPaymentAuthorizationResult(status: .failure, errors: errors)
                completion(result)
            }
        }
    }

    public func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        if _paymentState == .pendingPaymentProcessing {
            _paymentState = .timeout
        }
        
        dismissController(controller) {
            self._delegate?.applePayDismissed?(
                from: self,
                with: self._paymentState.toPaymentStatus(),
                error: self._error
            )
            
            self.cleanup()
        }
    }
    
    public func presentationWindow(for controller: PKPaymentAuthorizationController) -> UIWindow? {
        return _presentationWindow
    }
    
    private func cleanup() {
        if let authorizationController = _authController {
            objc_setAssociatedObject(
                authorizationController, 
                UnsafeRawPointer(&_applePayLauncherAssociatedObjectKey),
                nil,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
        _authController = nil
        _paymentState = .notStarted
    }
    
    private func dismissController(
        _ controller: PKPaymentAuthorizationController?,
        completion: @escaping OPVoidBlock
    ) {
        controller?.dismiss {
            dispatchToMainThreadIfNecessary {
                completion()
            }
        }
    }
    
    private func createPaymentRequest(
        with config: OPApplePayConfiguration,
        for amount: NSDecimalNumber,
        with lineItems: [PKPaymentSummaryItem]?
    ) -> PKPaymentRequest {
        let paymentRequest = PKPaymentRequest()
        
        paymentRequest.merchantIdentifier = config.merchantId
        paymentRequest.countryCode = config.countryCode
        paymentRequest.currencyCode = config.currencyCode.description
        paymentRequest.supportedNetworks = OPApplePayLauncher.supportedCardNetworks
        paymentRequest.merchantCapabilities = .threeDSecure
        paymentRequest.requiredBillingContactFields = [.postalAddress]
        paymentRequest.paymentSummaryItems = lineItems ?? []
        paymentRequest.paymentSummaryItems.append(PKPaymentSummaryItem(label: config.companyLabel, amount: amount))
        
        var shippingContactFields: Set<PKContactField> = []
        if config.emailRequired {
            shippingContactFields.insert(.emailAddress)
        }

        if config.phoneNumberRequired {
            shippingContactFields.insert(.phoneNumber)
        }
        
        paymentRequest.requiredShippingContactFields = shippingContactFields
        
        return paymentRequest
    }
}

internal enum ApplePayState: Int {
    case notStarted
    case pending
    case pendingPaymentProcessing
    case success
    case error
    case timeout
    
    func toPaymentStatus() -> OPApplePayStatus {
        switch self {
        case .notStarted:
            return .error
        case .pending:
            return .userCancellation
        case .pendingPaymentProcessing, .timeout:
            return .timeout
        case.success:
            return .success
        case .error:
            return .error
        }
    }
}
