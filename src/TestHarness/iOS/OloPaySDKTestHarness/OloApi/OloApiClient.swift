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

class OloApiClient {
    private let _baseUrl: String
    private let _apiKey: String
    
    init(baseUrl: String, apiKey: String) {
        _baseUrl = baseUrl.hasSuffix("/") ? baseUrl : "\(baseUrl)/"
        _apiKey = apiKey
    }
    
    func createBasket(restaurantId: UInt64, completion: @escaping (_: Basket?, _: Error?, _: String?) -> Void) {
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

    func setBasketHandoffMode(to handoffMode: String, basketId: String,  completion: @escaping (_: Basket?, _: Error?, _: String?) -> Void) {
        let url = createUrl(url: "baskets/\(basketId)/deliverymode")
        let data = [ "deliverymode" : handoffMode ]
        
        makeRequest(apiUrl: url, data: data, httpMethod: .put) { data, error in
            self.parseResponse(from: data, type: Basket.self) { basket, message in
                completion(basket, error, message)
            }
        }
    }
    
    func setBasketTimeModeAsap(basketId: String, completion: @escaping (_: Basket?, _: Error?, _: String?) -> Void) {
        let url = createUrl(url: "baskets/\(basketId)/timewanted")
        
        makeRequest(apiUrl: url, data: nil, httpMethod: .delete) { data, error in
            self.parseResponse(from: data, type: Basket.self) { basket, message in
                completion(basket, error, message)
            }
        }
    }
    
    func addProductToBasket(productId: UInt64, productQuantity: UInt, basketId: String, completion: @escaping (_: Basket?, _: Error?, _: String?) -> Void) {
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
    
    func submitBasket(with paymentMethod: OPPaymentMethodProtocol, basketId: String, email: String, billingSchemeId: String?, completion: @escaping (_: Order?, _: Error?, _: String?) -> Void) {
        let url = createUrl(url: "baskets/\(basketId)/submit")
        var data = [
            "billingmethod" : paymentMethod.isApplePay ? "digitalwallet" : "creditcardtoken",
            "usertype" : "guest",
            "firstname" : "Ron",
            "lastname" : "Idaho",
            "emailaddress" : email,
            "contactnumber" : "5555558901",
            "expiryyear" : String(describing: paymentMethod.expirationYear!),
            "expirymonth" : String(describing: paymentMethod.expirationMonth!),
            "saveonfile" : "false",
            "guestoptin" : "false",
            "token" : paymentMethod.id,
            "cardtype" : paymentMethod.cardType.description,
            "cardlastfour" : paymentMethod.last4!,
            "zip": paymentMethod.postalCode ?? "", //NOTE: If postal code is empty the API call will fail
            "streetaddress" : "26 Broadway",
            "city" : "NYC",
            "state" : "NY",
            "country" : paymentMethod.country ?? "US"
        ]
        
        if (billingSchemeId != nil)
        {
            data["billingschemeid"] = billingSchemeId!
        }
        
        makeRequest(apiUrl: url, data: data) { data, error in
            self.parseResponse(from: data, type: Order.self) { order, message in
                completion(order, error, message)
            }
        }
    }
    
    private func makeRequest(apiUrl: String, data: [String : String]?, httpMethod: HttpMethod = .post, completion: @escaping (_: Data?, _: Error?) -> Void) {
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
