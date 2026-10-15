// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  Product.swift
//  OloPaySDKTestHarness
//
//  Created by Justin Anderson on 7/10/21.
//

import Foundation

// This is just a bare-bones class that only stores the minimum amount of Product-related data needed
// for the test harness
class Product: NSObject, Decodable {
    let id: UInt64
    let productId: UInt64
    let name: String
    let quantity: Int
    
    override var description: String {
        let properties = [
            String(format: "%@: %p", NSStringFromClass(Product.self), self),
            "id = \(String(describing: id))",
            "productId = \(String(describing: productId))",
            "name = \(String(describing: name))",
            "quantity = \(String(describing: quantity))"
        ]
        
        return "<\(properties.joined(separator: "; "))>"
    }
}
