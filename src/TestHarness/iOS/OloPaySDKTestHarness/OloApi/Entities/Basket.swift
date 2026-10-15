// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  Basket.swift
//  OloPaySDKTestHarness
//
//  Created by Justin Anderson on 7/9/21.
//

import Foundation

// This is just a bare-bones class that only stores the minimum amount of Basket-related data needed
// for the test harness
class Basket : NSObject, Decodable {
    let id: String
    let vendorId: String?
    let mode: String?
    let deliveryMode: String?
    let timeWanted: String?
    let total: Decimal?
    let products: [Product?]?
    
    override var description: String {
        let properties = [
            String(format: "%@: %p", NSStringFromClass(Basket.self), self),
            "id = \(String(describing: id))",
            "vendorId = \(String(describing: vendorId))",
            "mode = \(String(describing: mode))",
            "deliveryMode = \(String(describing: deliveryMode))",
            "timeWanted = \(String(describing: timeWanted))",
            "total = \(String(describing: total))",
            "products = \(String(describing: products))"
        ]
        
        return "<\(properties.joined(separator: "; "))>"
    }
}
