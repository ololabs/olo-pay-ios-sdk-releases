// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OloPayAPI.swift
//  OloPaySDK
//
//  Created by Justin Anderson on 6/11/21.
//

import Foundation
import PassKit
import UIKit
import Stripe

/// Protocol for mocking/testing purposes. See `OloPayAPI` for documentation
@objc public protocol OloPayAPIProtocol : NSObjectProtocol {
    /// See `OloPayAPI.createPaymentMethod(...)` for documentation
    @available(swift, deprecated: 1.0, message: "Deprecated in Olo Pay SDK v1.0.2: Use createPaymentMethod(with: OPPaymentMethodParams, completion: OPPaymentMethodCompletionBlock) instead.")
    @objc(createPaymentMethodWithPaymentForm:completion:)
    func createPaymentMethod(with paymentForm: OPPaymentCardDetailsForm, completion: @escaping OPPaymentMethodCompletionBlock)
    
    /// See `OloPayAPI.createPaymentMethod(...)` for documentation
    @available(swift, deprecated: 1.0, message: "Deprecated in Olo Pay SDK v1.0.2: Use createPaymentMethod(with: OPPaymentMethodParams, completion: OPPaymentMethodCompletionBlock) instead.")
    @objc(createPaymentMethodWithPaymentControl:completion:)
    func createPaymentMethod(with paymentControl: OPPaymentCardDetailsView, completion: @escaping OPPaymentMethodCompletionBlock)
    
    /// See `OloPayAPI.createPaymentMethod(...)` for documentation
    @available(swift, introduced: 1.0, message: "Introduced in Olo Pay SDK v1.0.2")
    @objc(createPaymentMethodWithPaymentMethodParams:completion:)
    func createPaymentMethod(with params: OPPaymentMethodParamsProtocol, completion: @escaping OPPaymentMethodCompletionBlock)
    
    /// See `OloPayAPI.deviceSupportsApplePay()` for documentation
    @objc func deviceSupportsApplePay() -> Bool
    
    /// See `OloPayAPI.createPaymentRequest(...)` for documentation
    @objc func createPaymentRequest(forAmount amount: NSDecimalNumber, inCountry country: String, withCurrency currency: String) throws -> PKPaymentRequest
}

/// Represents the OloPayAPI and functionality related to it
/// - Important: Prior to calling methods in this class be sure to initialize the SDK by calling `OloPayApiInitializer.setup`
@objc public class OloPayAPI : NSObject, OloPayAPIProtocol {
    /// Creates an `OPPaymentMethod` instance with the provided control.
    /// - Warning: This method was deprecated in v1.0.2. Please use `createPaymentMethod(with: OPPaymentMethodParams, completion: OPPaymentMethodCompletionBlock)`
    /// - Parameters:
    ///   - paymentForm:  The `OPPaymentCardDetailsForm` from the UI.
    ///   - completion:   The callback to run with the returned `OPPaymentMethod` instance, or an error
    @available(swift, deprecated: 1.0, message: "Deprecated in Olo Pay SDK v1.0.2: Use createPaymentMethod(with: OPPaymentMethodParams, completion: OPPaymentMethodCompletionBlock) instead.")
    @objc(createPaymentMethodWithPaymentForm:completion:)
    public func createPaymentMethod(with paymentForm: OPPaymentCardDetailsForm, completion: @escaping OPPaymentMethodCompletionBlock) {
        guard paymentForm.isValid, let paymentParams = paymentForm.getPaymentMethodParams() else {
            completion(nil, OPError(cardErrorType: OPCardErrorType.unknownCardError, description: OPStrings.generalCardError))
            return
        }
        
        createPaymentMethod(with: paymentParams, firstTry: true, completion: completion)
    }

    /// Creates an `OPPaymentMethod` instance with the provided control.
    /// - Warning: This method was deprecated in v1.0.2. Please use `createPaymentMethod(with: OPPaymentMethodParams, completion: OPPaymentMethodCompletionBlock)`
    /// - Parameters:
    ///   - paymentControl:  The `OPPaymentCardDetailsView` from the UI
    ///   - completion:      The callback to run with the returned `OPPaymentMethod` instance, or an error.
    @available(swift, deprecated: 1.0, message: "Deprecated in Olo Pay SDK v1.0.2: Use createPaymentMethod(with: OPPaymentMethodParams, completion: OPPaymentMethodCompletionBlock) instead.")
    @objc(createPaymentMethodWithPaymentControl:completion:)
    public func createPaymentMethod(with paymentControl: OPPaymentCardDetailsView, completion: @escaping OPPaymentMethodCompletionBlock) {
        do
        {
            let paymentParams = try paymentControl.getPaymentMethodParams()
            createPaymentMethod(with: paymentParams, firstTry: true, completion: completion)
        }
        catch {
            completion(nil, error)
        }
    }
    
    /// Creates an `OPPaymentMethod` object with provided parameters
    ///
    /// - Parameters:
    ///   - paymentParameters:  The `OPPaymentMethodParams` supplied either by an `OPPaymentCardDetailsView` or `OPPaymentCardDetailsForm`.
    ///   - completion:         The callback to run with the returned `OPPaymentMethod` instance, or an error.
    @available(swift, introduced: 1.0, message: "Introduced in Olo Pay SDK v1.0.2")
    @objc(createPaymentMethodWithPaymentMethodParams:completion:)
    public func createPaymentMethod(with params: OPPaymentMethodParamsProtocol, completion: @escaping OPPaymentMethodCompletionBlock) {
        createPaymentMethod(with: params, firstTry: true, completion: completion)
    }
    
    /// Whether or not this device can make Apple Pay payments via a  supported card network
    /// Supported ApplePay card networks are: American Express, Visa, Mastercard, Discover
    ///
    /// - Returns: YES if the device is currently able to make Apple Pay payments via one
    /// of the supported networks. NO if the user does not have a saved card of a
    /// supported type, or other restrictions prevent payment (such as parental controls).
    @objc public func deviceSupportsApplePay() -> Bool { StripeAPI.deviceSupportsApplePay() }
    
    /// A convenience method to build a `PKPaymentRequest` with sane default values.
    ///
    /// - Important: `OloPayApiInitializer.setup(...)` must have been called with both the Apple Pay merchant id and company name prior to calling this method
    ///
    /// - Parameters:
    ///   - forAmount:      The amount to charge
    ///   - inCountry:      The two-letter code for the payment country  (Defaults to "US")
    ///   - withCurrency:   The three-letter code for the currency (Defaults to "USD"). ApplePay interprets the amounts provided by the summary items attached to this request as amounts in this currency.
    ///
    /// - Returns: a `PKPaymentRequest` with proper default values
    ///
    /// - Throws: Throws `OPApplePayContextError.missingMerchantId` or `OPApplePayContextError.missingCompanyLabel`
    @objc public func createPaymentRequest(forAmount amount: NSDecimalNumber, inCountry country: String = "US", withCurrency currency: String = "USD") throws -> PKPaymentRequest {
        guard let merchant = OPApplePayContext.merchantId, !merchant.isEmpty else {
            print("OPApplePayContext: merchantId must be set before calling createPaymentRequest()")
            throw OPApplePayContextError.missingMerchantId
        }
        
        guard let company = OPApplePayContext.companyLabel, !company.isEmpty else {
            print("OPApplePayContext: companyLabel must be set before calling createPaymentRequest()")
            throw OPApplePayContextError.missingCompanyLabel
        }
        
        let request = StripeAPI.paymentRequest(withMerchantIdentifier: merchant, country: country, currency: currency)
        request.paymentSummaryItems = [ PKPaymentSummaryItem(label: company, amount: amount) ]
        
        return request
    }
    
    private func createPaymentMethod(with params: OPPaymentMethodParamsProtocol, firstTry: Bool = true, completion: @escaping OPPaymentMethodCompletionBlock) {
        guard let paymentParams = params as? OPPaymentMethodParams else {
            completion(nil, OPError(cardErrorType: OPCardErrorType.unknownCardError, description: OPStrings.unsupportedCardError))
            return
        }
        
        let client = STPAPIClient.shared
        client.createPaymentMethod(with: paymentParams.paymentMethodParams) { paymentMethod, createPaymentMethodError in
            var oloPaymentMethod : OPPaymentMethod? = nil
            if (paymentMethod != nil) {
                oloPaymentMethod = OPPaymentMethod(paymentMethod: paymentMethod!)
               
                guard oloPaymentMethod?.cardType != .unknown && oloPaymentMethod?.cardType != .unsupported else {
                    let errorMessage = oloPaymentMethod?.cardType == .unsupported ? OPStrings.unsupportedCardError : OPStrings.invalidCardNumberError
                    completion(nil, OPError(cardErrorType: OPCardErrorType.invalidNumber, description: errorMessage))
                    return
                }
            }
           
            let wrappedError = OPError.wrapIfNeeded(from: createPaymentMethodError as NSError?)

            // Attempt to redownload the publishable key and try the call again, if needed
            if firstTry && self.invalidPublishableKey(with: wrappedError) {
                OloPayAPI.updatePublishableKey {
                    self.createPaymentMethod(with: params, firstTry: false, completion: completion)
                }

                return
            }

            completion(oloPaymentMethod, wrappedError)
        }
    }
    
    func invalidPublishableKey(with error: NSError?) -> Bool {
        guard let error = error as? OPError else {
            return false
        }

        return error.errorType == OPErrorType.authenticationError
    }
    
    static var publishableKey: String {
        get { OPStorage.publishableKey }
        set {
            OPStorage.publishableKey = newValue
            StripeAPI.defaultPublishableKey = newValue
        }
    }
    
    static var environment: OPEnvironment {
        get { OPEnvironment.convert(from: OPStorage.environment) }
        set { OPStorage.environment = newValue.description }
    }
    
    static func updatePublishableKey(completion: OPVoidBlock? = nil) {
        guard let url = environment.publishableKeyUrl else {
            print("Publishable key url not found")
            return
        }

        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else {
                if let completion = completion  { completion() }
                return
            }
            
            self.publishableKey = (try! JSONDecoder().decode(OPPublishableKey.self, from: data)).key
            if let completion = completion  { completion() }
        }

        task.resume()
    }
}
