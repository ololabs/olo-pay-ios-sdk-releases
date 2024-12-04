// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OloApiClient.swift
//  OloPaySDKTestHarness
//
//  Created by Justin Anderson on 7/8/21.
//

import Foundation
import UIKit
import OloPaySDK

typealias BasketApiCompletionBlock = (_: Basket?, _: Error?, _: String?) -> Void
typealias OrderApiCompletionBlock = (_: Order?, _: Error?, _: String?) -> Void
typealias UserApiCompletionBlock = (_: User?, _: Error?, _: String?) -> Void
typealias BillingAccountApiCompletionBlock = (_: [BillingAccount]?, _: Error?, _: String?) -> Void
typealias VoidApiCompletionBlock = (_: Error?, _: String?) -> Void
private typealias DataApiCompletionBlock = (_: Data?, _: Error?) -> Void

class OloApiClient {
    private let _baseUrl: String
    private let _apiKey: String
    
    init(baseUrl: String, apiKey: String) {
        _baseUrl = baseUrl.hasSuffix("/") ? baseUrl : "\(baseUrl)/"
        _apiKey = apiKey
    }
    
    func login(email: String, password: String, completion: @escaping UserApiCompletionBlock) {
        let url = createUrl(url: "users/authenticate")
        let postData = [
            "login" : email,
            "password" : password
        ]
        
        makeRequest(apiUrl: url, data: postData) { data, error in
            self.parseResponse(from: data, type: LoggedInUser.self) { loggedInUser, message in
                completion(loggedInUser?.user, error, message)
            }
        }
    }
    
    func logout(authToken: String, completion: @escaping VoidApiCompletionBlock) {
        let url = createUrl(url: "users/\(authToken)")
        let postData: [String : String] = [:]
        
        makeRequest(apiUrl: url, data: postData, httpMethod: .delete) { data, error in
            self.parseResponse(from: data, type: User.self) { user, message in
                completion(error, "")
            }
        }
    }
    
    func createBasket(restaurantId: UInt64, completion: @escaping BasketApiCompletionBlock) {
        let url = createUrl(url: "baskets/create")
        let postData = [
            "vendorid" : String(describing: restaurantId),
            "mode" : "orderahead"
        ]
        
        makeRequest(apiUrl: url, data: postData) { data, error in
            self.parseResponse(from: data, type: Basket.self) { basket, message in
                completion(basket, error, message)
            }
        }
    }

    func setBasketHandoffMode(to handoffMode: String, basketId: String,  completion: @escaping BasketApiCompletionBlock) {
        let url = createUrl(url: "baskets/\(basketId)/deliverymode")
        let data = [ "deliverymode" : handoffMode ]
        
        makeRequest(apiUrl: url, data: data, httpMethod: .put) { data, error in
            self.parseResponse(from: data, type: Basket.self) { basket, message in
                completion(basket, error, message)
            }
        }
    }
    
    func setBasketTimeModeAsap(basketId: String, completion: @escaping BasketApiCompletionBlock) {
        let url = createUrl(url: "baskets/\(basketId)/timewanted")
        
        makeRequest(apiUrl: url, data: nil, httpMethod: .delete) { data, error in
            self.parseResponse(from: data, type: Basket.self) { basket, message in
                completion(basket, error, message)
            }
        }
    }
    
    func addProductToBasket(productId: UInt64, productQuantity: UInt, basketId: String, completion: @escaping BasketApiCompletionBlock) {
        let url = createUrl(url: "baskets/\(basketId)/products")
        
        let data = [
            "productid" : String(describing: productId),
            "quantity" : String(describing: productQuantity),
            "options" : ""
        ]
        
        makeRequest(apiUrl: url, data: data) { data, error in
            self.parseResponse(from: data, type: Basket.self) { basket, message in
                completion(basket, error, message)
            }
        }
    }
    
    func availableBillingAccounts(authToken: String, basketId: String, completion: @escaping BillingAccountApiCompletionBlock) {
        let parameters = [
            "basket" : basketId
        ]
        
        let url = createUrl(url: "users/\(authToken)/billingAccounts", parameters: parameters)
        
        makeRequest(apiUrl: url, data: nil, httpMethod: .get) { data, error in
            self.parseResponse(from: data, type: BillingAccounts.self) { billingAccounts, message in
                completion(billingAccounts?.billingaccounts, error, message)
            }
        }
    }
    
    func submitBasket(with paymentType: PaymentType, user: User, basketId: String , billingId: String?, completion: @escaping OrderApiCompletionBlock) {
        let url = createUrl(url: "baskets/\(basketId)/submit")
        
        var data = [
            "usertype" : user.authtoken == nil ? "guest" : "user",
            "saveonfile" : "false",
            "streetaddress" : "26 Broadway",
            "city" : "NYC",
            "state" : "NY",
            "contactnumber" : "5555558901",
        ]
        
        if let authToken = user.authtoken {
            data["authtoken"] = authToken
        } else {
            data["firstname"] = user.firstname
            data["lastname"] = user.lastname
            data["emailaddress"] = user.emailaddress
            data["guestoptin"] = "false"
        }
        
        if let paymentMethod = paymentType.paymentMethod {
            data["billingmethod"] = paymentMethod.isApplePay ? "digitalwallet" : "creditcardtoken"
            data["expiryyear"] = String(describing: paymentMethod.expirationYear!)
            data["expirymonth"] = String(describing: paymentMethod.expirationMonth!)
            data["token"] = paymentMethod.id
            data["cardtype"] = paymentMethod.cardType.description
            data["cardlastfour"] = paymentMethod.last4!
            data["zip"] = paymentMethod.postalCode ?? "" //NOTE: If postal code is empty the API call will fail
            data["country"] = paymentMethod.country ?? "US"
            
            if let billingId = billingId, paymentMethod.isApplePay {
                data["billingschemeid"] = billingId
            }
            
        } else if let token = paymentType.cvvToken {
            data["billingmethod"] = "billingaccount"
            data["cvv"] = token.id
            
            if let billingId = billingId {
                data["billingaccountid"] = billingId
            }
        }
        
        makeRequest(apiUrl: url, data: data) { data, error in
            self.parseResponse(from: data, type: Order.self) { order, message in
                completion(order, error, message)
            }
        }
    }
    
    private func makeRequest(apiUrl: String, data: [String : String]?, httpMethod: HttpMethod = .post, completion: @escaping DataApiCompletionBlock) {
        guard let url = URL(string: apiUrl) else {
            return
        }
        
        var request = URLRequest(url: url)
        
        if httpMethod == .put || httpMethod == .delete {
            request.setValue(String(describing: httpMethod), forHTTPHeaderField: "X-HTTP-Method-Override")
            request.httpMethod = String(describing: HttpMethod.post)
        } else {
            request.httpMethod = String(describing: httpMethod)
        }
        
        if request.httpMethod == String(describing: HttpMethod.post) && data != nil {
            let jsonData = try? JSONSerialization.data(withJSONObject: data!)
            request.httpBody = jsonData
            
            request.setValue("\(String(describing: jsonData?.count))", forHTTPHeaderField: "Content-Length")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        request.setValue("OloPaySDKTestHarness/1.0", forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let deviceId = UIDevice.current.identifierForVendor?.uuidString {
            request.setValue(deviceId, forHTTPHeaderField: "X-Device-Id")
        }
        
        request.setValue("OloKey \(_apiKey)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            completion(data, error)
        }
        
        task.resume()
    }

    func parseResponse<T : Decodable>(from data: Data?, type: T.Type, completion: ((T?, String?) -> Void)) {
        guard let data = data else {
            completion(nil, "No response data to parse")
            return
        }
        
        do {
            let obj = try JSONDecoder().decode(T.self, from: data)
            completion(obj, nil)
        } catch {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any]
                completion(nil, String(describing: json))
            } catch {
                completion(nil, "Unable to parse json data")
            }
        }
    }
    
    private func createUrl(url: String, parameters: [String : String]? = nil) -> String {
        let newUrl = url.trimmingCharacters(in: ["/"])
        
        if (parameters == nil) {
            return "\(_baseUrl)\(newUrl)"
        }
        
        let queryString = createQueryString(with: parameters!)
        return "\(_baseUrl)\(newUrl)?\(queryString)"
    }

    private func createQueryString(with params: [String : String]) -> String {
        return params.map { "\($0)=\($1)" }.joined(separator: "&")
    }
}
