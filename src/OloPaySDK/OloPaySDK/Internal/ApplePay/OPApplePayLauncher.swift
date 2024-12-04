// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPApplePayLauncher.swift
//  OloPaySDK
//
//  Created by Justin Anderson on 6/21/23.
//

import Foundation
import PassKit
import Stripe
import ObjectiveC

@objc protocol OloApplePayLauncherDelegate: NSObjectProtocol {
    func paymentMethodCreated(
        _ launcher: OPApplePayLauncher,
        _ paymentMethod: OPPaymentMethod,
        _ paymentInfo: PKPayment,
        completion: @escaping OPApplePayCompletionBlock
    )
    
    @objc(applePayCompleted:status:error:)
    func applePayCompleted(
        _ launcher: OPApplePayLauncher,
        _ status: OPPaymentStatus,
        error: Error?
    )
}

@available(iOSApplicationExtension, unavailable)
@available(macCatalystApplicationExtension, unavailable)
@objc internal class OPApplePayLauncher: NSObject, PKPaymentAuthorizationControllerDelegate {
    private weak var _delegate: OloApplePayLauncherDelegate?
    private var _presentationWindow: UIWindow?
    private var _applePayLaunched = false
    private var _applePayLauncherAssociatedObjectKey = 0
    private var _paymentState = ApplePayState.notStarted
    private var _didCancelOrTimeoutWhilePending = false
    private var _error: Error?
    private var _merchantId: String?
    private var _companyLabel: String?
    @objc var _authController: PKPaymentAuthorizationController?
    
    
    @objc(initWithPaymentRequest:delegate:)
    public required init?(paymentRequest: PKPaymentRequest, delegate: OloApplePayLauncherDelegate?) {
        guard (StripeAPI.canSubmitPaymentRequest(paymentRequest)) else {
            return nil
        }
    
        super.init()
        
        _delegate = delegate
        _authController = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
        _authController?.delegate = self
    }
    
    public func presentApplePay(merchantId: String, companyLabel: String, completion: OPVoidBlock? = nil) {
        dispatchToMainThreadIfNecessary {
            let window = UIApplication.shared.windows.first { $0.isKeyWindow }
            self.presentApplePay(from: window, merchantId: merchantId, companyLabel: companyLabel, completion: completion)
        }
    }
    
    @objc(presentApplePayFromWindow:withMerchantId:withCompanyLabel:withCompletion:)
    public func presentApplePay(from window: UIWindow?, merchantId: String, companyLabel: String, completion: OPVoidBlock? = nil) {
        _presentationWindow = window
        _merchantId = merchantId
        _companyLabel = companyLabel
        
        guard !_applePayLaunched, let applePayController = self._authController else {
            return
        }
        _applePayLaunched = true
        
        // This instance must live so that the apple pay sheet is dismissed; until then, the app is effectively frozen.
        objc_setAssociatedObject(
            applePayController, UnsafeRawPointer(&_applePayLauncherAssociatedObjectKey), self,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        applePayController.present { (presented) in
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
        completePayment(with: payment) { status, error in
            let errors = [STPAPIClient.pkPaymentError(forStripeError: error)].compactMap({ $0 })
            let result = PKPaymentAuthorizationResult(status: status, errors: errors)
            completion(result)
        }
    }
    
    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        // Note: If you don't dismiss the VC, the UI disappears, the VC blocks interaction, and this method gets called again.
        // Note: This method is called if the user cancels (taps outside the sheet) or Apple Pay times out (empirically 30 seconds)
        switch _paymentState {
        case .notStarted:
            dismissController(controller) {
                self._delegate?.applePayCompleted(self, .userCancellation, error: nil)
                self.endApplePay()
            }
        case .pending:
            // We can't cancel a pending payment. If we dismiss the VC now, the customer might interact with the app
            // and miss seeing the result of the payment - risking a double charge, chargeback, etc. Instead, we'll
            // dismiss and notify our delegate when the payment finishes.
            _didCancelOrTimeoutWhilePending = true
        case .error:
            dismissController(controller) {
                self._delegate?.applePayCompleted(self, .error, error: self._error)
                self.endApplePay()
            }
        case .success:
            dismissController(controller) {
                self._delegate?.applePayCompleted(self, .success, error: nil)
                self.endApplePay()
            }
        }
    }
    
    public func presentationWindow(for controller: PKPaymentAuthorizationController) -> UIWindow? {
        return _presentationWindow
    }
    
    private func completePayment(with payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus, Error?) -> Void) {
        // Helper to handle annoying logic around "Do I call completion block or dismiss + call delegate?"
        let handleFinalState: ((ApplePayState, Error?) -> Void) = { state, error in
            switch state {
            case .error:
                self._paymentState = .error
                self._error = error
                if self._didCancelOrTimeoutWhilePending {
                    self.dismissController(self._authController){
                        self._delegate?.applePayCompleted(self, .error, error: self._error)
                        self.endApplePay()
                    }
                } else {
                    completion(PKPaymentAuthorizationStatus.failure, self._error)
                }
            case .success:
                self._paymentState = .success
                if self._didCancelOrTimeoutWhilePending {
                    self.dismissController(self._authController){
                        self._delegate?.applePayCompleted(self, .success, error: nil)
                        self.endApplePay()
                    }
                } else {
                    completion(PKPaymentAuthorizationStatus.success, nil)
                }
            case .pending, .notStarted:
                assert(false, "Invalid final state")
                return
            }
        }
        
        let client = STPAPIClient.shared
        let metadata = OPMetadataGenerator(applePayMerchantId: _merchantId, applePayCompanyLabel: _companyLabel).generate()
        client.createPaymentMethod(with: payment, metadata: metadata) { paymentMethod, paymentMethodError in
            if let paymentMethod = paymentMethod, paymentMethodError == nil, self._authController != nil {
                guard let launcherDelegate = self._delegate else {
                    handleFinalState(.error, nil)
                    return
                }
                
                let opPaymentMethod = OPPaymentMethod(paymentMethod: paymentMethod)
                launcherDelegate.paymentMethodCreated(self, opPaymentMethod, payment) { intentCreationError in
                    if intentCreationError == nil && self._authController != nil {
                        handleFinalState(.success, nil)
                    } else {
                        handleFinalState(.error, intentCreationError)
                    }
                }
            } else {
                handleFinalState(.error, paymentMethodError)
            }
        }
    }
    
    private func endApplePay() {
        if let authorizationController = _authController {
            objc_setAssociatedObject(
                authorizationController, UnsafeRawPointer(&_applePayLauncherAssociatedObjectKey),
                nil,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        _authController = nil
        _delegate = nil
    }
    
    private func dismissController(_ controller: PKPaymentAuthorizationController?, completion: @escaping OPVoidBlock) {
        controller?.dismiss {
            dispatchToMainThreadIfNecessary {
                completion()
            }
        }
    }
}

internal enum ApplePayState: Int {
    case notStarted
    case pending
    case error
    case success
}
