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
    
    func submitBasketFromSettings(with paymentMethod: OPPaymentMethodProtocol, basketId: String, billingSchemeId: String?, completion: @escaping (_: Order?, _: Error?, _: String?) -> Void) {
        let email = TestHarnessSettings.sharedInstance.userEmail!
        
        submitBasket(with: paymentMethod, basketId: basketId, email: email, billingSchemeId: billingSchemeId, completion: completion)
    }
    
    func createBasketWithProductFromSettings(completion: @escaping (_: Basket?, _: Error?, _: String?) -> Void) {
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
}
