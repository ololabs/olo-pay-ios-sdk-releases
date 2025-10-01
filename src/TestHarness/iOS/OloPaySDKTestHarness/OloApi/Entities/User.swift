// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  User.swift
//  OloPaySDKTestHarness
//
//  Created by Justin Anderson on 10/16/23.
//

import Foundation

class User : NSObject, Decodable {
    let authtoken: String?
    let emailaddress: String
    let firstname: String
    let lastname: String
    
    init(email: String, firstName: String, lastName: String) {
        authtoken = nil
        emailaddress = email
        firstname = firstName
        lastname = lastName
    }
}
