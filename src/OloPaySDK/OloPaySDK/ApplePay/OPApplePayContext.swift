// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPApplePayContext.swift
//  OloPaySDK
//
//  Created by Justin Anderson on 6/16/21.
//
import Foundation
import Stripe
import PassKit

/// Protocol to hook into important events in the ApplePay flow
///
/// __Required:__ Implement `applePaymentMethodCreated`to get payment method details that need to be submitted to Olo's Ordering API when submitting a basket with OloPay
///
/// __Optional:__ Implement `applePaymentCompleted` to know when the ApplePay sheet is dismissed
@objc public protocol OPApplePayContextDelegate: NSObjectProtocol {
    /// Called after the customer has authorized ApplePay and a payment method has been created.  Implement this method to pass the payment method ID to Olo's Ordering API
    /// when submitting a basket. If the API call returns an error, return that error so the ApplePay payment sheet can be dismissed appropriately
    /// - Parameters:
    ///     - paymentMethod: The PaymentMethod that represents the customer's Apple Pay payment method.
    /// - Returns: nil if basket submission was successful, or an Error from Olo's Ordering API if submission was unsuccessful
    @objc func applePaymentMethodCreated(_ context: OPApplePayContextProtocol, didCreatePaymentMethod paymentMethod: OPPaymentMethodProtocol) -> NSError?
    
    /// Called after the Apple Pay sheet is dismissed with the result of the payment.
    /// Your implementation could stop a spinner and display a receipt view or error to the customer, for example.
    /// - Parameters:
    ///   - status:     The status of the payment
    ///   - error:      The error that occurred, if any. This will generally be `OPError`. If the error has an `errorType` of `cardError` it will also contain a user-friendly message
    ///                 that can be used to help the user understand why the payment couldn't be completed.
    @objc optional func applePaymentCompleted(_ context: OPApplePayContextProtocol, didCompleteWith status: OPPaymentStatus, error: Error?)
}

/// Protocol for mocking/testing purposes. See `OPApplePayContext` for documentation
@objc public protocol OPApplePayContextProtocol : NSObjectProtocol {
    /// See `OPApplePayContext.basketId` for documentation
    @objc var basketId: String? { get set }
    
    /// See `OPApplePayContext.presentApplePay(...)` for documentation
    @objc func presentApplePay(completion: OPVoidBlock?) throws

    /// See `OPApplePayContext.presentApplePay(...)` for documentation
    @objc func presentApplePay(merchantId: String, companyLabel: String, completion: OPVoidBlock?) throws
}

/// A helper class that implements and simplifies ApplePay.
///
/// Use of this class looks like this:
/// 1. Create a button for ApplePay and connect it to a click handler
/// 2. Enable/Disable or Hide/Show the ApplePay button by calling `OloPayAPI.deviceSupportsApplePay()`
/// 3. In the click handler, do the following
///     1. Check the device supports ApplePay
///     2. Create a `PKPaymentRequest` describing the request (amount, line items, etc)... An easy way to do this is to use the `OloPayAPI.createPaymentRequest(...)` helper function
///     3. Initialize this class with the payment request from the previous step
///     4. Call presentApplePay() to present the Apple Pay sheet and begin the payment process
/// 4. Implement `OPApplePayContextDelegate.applePaymentMethodCreated(...)` to submit the basket to Olo's Ordering API
/// 5. Optionally implement `OPApplePayContextDelegate.applePaymentCompleted(...)` to handle success and error states when the ApplePay sheet is dimissed
///
/// - Important: Create a new instance of this class for every payment request
/// - Warning: OPApplePayContext needs to be created as a  class member variable rather than a variable with function scope or else it can become
///            `nil` while the ApplePay sheet is presented and callback methods won't get called
///
/// __Example Implementation__
/// ```
/// class ViewController: UIViewController, OPApplePayContextDelegate {
///     // This needs to be a class member variable or it can go out of
///     // scope during the ApplePay flow and become nil, preventing callbacks
///     // from executing
///     var _applePayContext: OPApplePayContextProtocol? = nil
///
///     // Called when user taps on ApplePay button to begin ApplePay flow
///     func submitApplePay() {
///         let api: OloPayAPIProtocol = OloPayAPI() //This can be mocked for testing purposes
///         guard api.deviceSupportsApplePay() else {
///             return
///         }
///
///         do {
///             let pkPaymentRequest = try api.createPaymentRequest(forAmount: 2.99, inCountry: "US", withCurrency: "USD")
///             _applePayContext = OPApplePayContext(paymentRequest: pkPaymentRequest, delegate: self) //This can be mocked for testing purposes
///             _applePayContext?.presentApplePay() {
///                 // Optional logic for when the ApplePay flow is displayed
///             }
///         }
///         catch {
///             // Handle error conditions. See docs for `OPApplePayContext.presentApplePay()` for more information
///         }
///     }
///
///     func applePaymentMethodCreated(_ context: OPApplePayContextProtocol, didCreatePaymentMethod paymentMethod: OPPaymentMethod) -> NSError? {
///         // Use the payment method to submit the basket to Olo's Ordering API (the basket id can be retrieved with `context.basketId`
///         // If the API returns an error, return that error. If the API call is successful, return nil
///     }
///
///     func applePaymentCompleted(_ context: OPApplePayContextProtocol, didCompleteWith status: OPPaymentStatus, error: Error?) {
///         // This is called after the payment sheet has been dismissed
///         // Use the status and error parameters to determine if payment was successful
///     }
/// }
/// ```
@objc public class OPApplePayContext : NSObject, OloApplePayLauncherDelegate, OPApplePayContextProtocol {
    var _applePayLauncher: OPApplePayLauncher?
    var _delegate: OPApplePayContextDelegate?
    var _applePayPresented: Bool
    
    static var merchantId: String?
    static var companyLabel: String?
    
    /// Basket ID convenience property for being able to submit a basket in `OPApplePayContextDelegate.applePaymentMethodCreated(...)`
    @objc public var basketId: String?
    
    /// Initializes this class.
    /// - Parameters:
    ///   - paymentRequest: The payment request to use with Apple Pay.
    ///   - delegate:       The delegate.
    ///   - basketId:       The id of the basket associated with this context. Useful in `OPApplePayContextDelegate.applePaymentMethodCreated(...)`
    /// - Returns: An `OPApplePayContext` instance or `nil` if the request is invalid (e.g. the user is restricted by parental controls or can't make
    ///            payments on any of the requests supported networks
    @objc public required init?(paymentRequest: PKPaymentRequest, delegate: OPApplePayContextDelegate, basketId: String? = nil) {
        _applePayPresented = false
        _delegate = delegate
        self.basketId = basketId
        super.init()
        
        _applePayLauncher = OPApplePayLauncher(paymentRequest: paymentRequest, delegate: self)
        if (_applePayLauncher == nil) {
            return nil
        }
    }
    
    /// Presents the Apple Pay sheet from the key window (using the merchant id and company label set in `OloPayAPI.setup(...)`) and starts the payment process.
    ///
    /// - Important: This method can only be called once per `OPApplePayContext` instance. Subsequent calls to this method will result in a no-op
    ///
    /// - Parameters:
    ///   - completion: Called after the Apple Pay sheet is visible to the user
    ///   
    /// - Throws: Throws `OPApplePayContextError.missingMerchantId`, `OPApplePayContextError.emptyMerchantId`,
    ///           `OPApplePayContextError.missingCompanyLabel`, or `OPApplePayContextError.emptyCompanyLabel`
    @objc public func presentApplePay(completion: OPVoidBlock? = nil) throws {
        guard !_applePayPresented else {
            return
        }

        guard let merchantId = OPApplePayContext.merchantId else {
            print("OPApplePayContext: merchantId must be set before calling createPaymentRequest()")
            throw OPApplePayContextError.missingMerchantId
        }

        guard let companyLabel = OPApplePayContext.companyLabel else {
            print("OPApplePayContext: companyLabel must be set before calling createPaymentRequest()")
            throw OPApplePayContextError.missingCompanyLabel
        }

        try presentApplePay(merchantId: merchantId, companyLabel: companyLabel, completion: completion)
    }
    
    /// Presents the Apple Pay sheet from the key window and starts the payment process.
    ///
    /// - Important: This method can only be called once per `OPApplePayContext` instance. Subsequent calls to this method will result in a no-op
    ///
    /// - Parameters:
    ///   - merchantId: The merchant id to be used for this Apple Pay transaction. This overrides the value set in `OloPayAPI.setup(...)`
    ///   - companyLabel: The company label to be used for this Apple Pay transaction. This overrides the value set in `OloPayAPI.setup(...)`
    ///   - completion: Called after the Apple Pay sheet is visible to the user
    ///
    /// - Throws: Throws `OPApplePayContextError.emptyMerchantId` or `OPApplePayContextError.emptyCompanyLabel`
    @objc public func presentApplePay(merchantId: String, companyLabel: String, completion: OPVoidBlock? = nil) throws {
        guard !_applePayPresented else {
            return
        }

        if merchantId.isEmpty {
            print("OPApplePayContext: merchantId cannot be empty")
            throw OPApplePayContextError.emptyMerchantId
        }

        if companyLabel.isEmpty {
            print("OPApplePayContext: companyLabel cannot be empty")
            throw OPApplePayContextError.emptyCompanyLabel
        }

        _applePayPresented = true
        _applePayLauncher?.presentApplePay(merchantId: merchantId, companyLabel: companyLabel, completion: completion)
    }

    func paymentMethodCreated(_ launcher: OPApplePayLauncher, _ paymentMethod: OPPaymentMethod, _ paymentInfo: PKPayment, completion: @escaping OPApplePayCompletionBlock) {
        let result = self._delegate?.applePaymentMethodCreated(self, didCreatePaymentMethod: paymentMethod)
        completion(result)
    }

    func applePayCompleted(_ launcher: OPApplePayLauncher, _ status: OPPaymentStatus, error: Error?) {
        guard let paymentCompleted = self._delegate?.applePaymentCompleted else {
            return
        }
        
        let wrappedError = OPError.wrapIfNeeded(from: error as NSError?)
        paymentCompleted(self, status, wrappedError)
    }
}
