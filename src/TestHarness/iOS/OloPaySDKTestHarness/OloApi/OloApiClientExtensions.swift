// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OloApiClientExtensions.swift
//  OloPaySDKTestHarness
//
//  Created by Justin Anderson on 7/10/21.
//

import Foundation
import OloPaySDK

extension OloApiClient {
    static func createFromSettings() -> OloApiClient? {
        guard let apiUrl = TestHarnessSettings.sharedInstance.baseAPIUrl, let apiKey = TestHarnessSettings.sharedInstance.apiKey else {
            return nil
        }
        
        return OloApiClient(baseUrl: apiUrl, apiKey: apiKey)
    }
    
    func submitBasketFromSettings(with paymentMethod: OPPaymentMethodProtocol, basketId: String, completion: @escaping OrderApiCompletionBlock) {
        guard let email = TestHarnessSettings.sharedInstance.userEmail, !email.isEmpty else {
            completion(nil, nil, "Unable to submit basket: User email not set")
            return
        }
        
        var billingId: String? = nil
        if paymentMethod.isApplePay {
            guard let applePayBillingId = TestHarnessSettings.sharedInstance.applePayBillingSchemeId else {
                completion(nil, nil, "Unable to submit basket: Apple Pay Billing Scheme Id not set")
                return
            }
            
            billingId = applePayBillingId
        }
        
        if !TestHarnessSettings.sharedInstance.useLoggedInUser {
            submitBasket(
                with: PaymentType(paymentMethod),
                user: getGuestUser(),
                basketId: basketId,
                billingId: billingId,
                completion: completion)
        } else {
            guard let password = TestHarnessSettings.sharedInstance.userPassword, !password.isEmpty else {
                completion(nil, nil, "Unable to submit basket - User password not set")
                return
            }
            
            login(email: email, password: password) { user, error, message in
                guard let user = user, let userAuthToken = user.authtoken else {
                    completion(nil, error, message)
                    return
                }
                
                self.submitBasket(
                    with: PaymentType(paymentMethod),
                    user: user,
                    basketId: basketId,
                    billingId: billingId) { order, error, message in
                        
                        // In a real-world application you would not want to log the user out after completing an order
                        self.logout(authToken: userAuthToken) { error, message in
                            //Do nothing here... we don't need to notify about a failed logout call
                        }
                        
                        completion(order, error, message)
                    }
            }
        }
    }
    
    func submitBasketFromSettings(with cvvToken: OPCvvUpdateTokenProtocol, basketId: String, completion: @escaping OrderApiCompletionBlock) {
        guard let billingId = TestHarnessSettings.sharedInstance.savedCardBillingAccountId, !billingId.isEmpty else {
            completion(nil, nil, "Unable to submit basket - Saved Card Billing Acount Id not set")
            return
        }
        
        guard let email = TestHarnessSettings.sharedInstance.userEmail, !email.isEmpty else {
            completion(nil, nil, "Unable to submit basket - User email not set")
            return
        }
        
        guard let password = TestHarnessSettings.sharedInstance.userPassword, !password.isEmpty else {
            completion(nil, nil, "Unable to submit basket - User password not set")
            return
        }
        
        login(email: email, password: password) { user, error, message in
            guard let user = user, let authToken = user.authtoken else {
                completion(nil, error, message)
                return
            }
            
            self.availableBillingAccounts(authToken: authToken, basketId: basketId) { billingAccounts, error, message in
                guard let billingAccounts = billingAccounts else {
                    completion(nil, error, message)
                    return
                }
                
                let validBillingAccount = !billingAccounts.filter({ $0.accountidstring == billingId}).isEmpty
                guard validBillingAccount else {
                    completion(nil, nil, "Unable to submit basket - Saved billing account id not valid")
                    return
                }
                
                self.submitBasket(
                    with: PaymentType(cvvToken),
                    user: user,
                    basketId: basketId,
                    billingId: billingId,
                    completion: completion)
            }
        }
    }
    
    func createBasketWithProductFromSettings(completion: @escaping BasketApiCompletionBlock) {
        guard let vendorId = TestHarnessSettings.sharedInstance.restaurantId else {
            completion(nil, nil, "Basket Not Created - No restaurant id set")
            return
        }
        
        guard let productId = TestHarnessSettings.sharedInstance.productId else {
            completion(nil, nil, "Basket Not Created - No Product Id set")
            return
        }
        
        guard let quantity = TestHarnessSettings.sharedInstance.productQty else {
            completion(nil, nil, "Basket Not Created - No Product Qty set")
            return
        }
        
        createBasket(restaurantId: vendorId) { basket, error, message in
            guard let basket = basket else {
                completion(nil, error, message)
                return
            }
            
            self.setBasketHandoffMode(to: "pickup", basketId: basket.id) { handoffBasket, handoffError, handoffMessage in
                guard let handoffBasket = handoffBasket else {
                    completion(nil, handoffError, handoffMessage)
                    return
                }
                
                self.setBasketTimeModeAsap(basketId: handoffBasket.id) { asapBasket, asapError, asapMessage in
                    guard let asapBasket = asapBasket else {
                        completion(nil, asapError, asapMessage)
                        return
                    }
                    
                    self.addProductToBasket(productId: productId, productQuantity: quantity, basketId: asapBasket.id) { productBasket, productError, productMessage in
                        completion(productBasket, productError, productMessage)
                    }
                }
            }
        }
    }
    
    private func getGuestUser() -> User {
        return User(email: TestHarnessSettings.sharedInstance.userEmail ?? "", firstName: "Ron", lastName: "Idaho")
    }
}
