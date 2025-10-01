// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  LoggedInUser.swift
//  OloPaySDKTestHarness
//
//  Created by Justin Anderson on 10/16/23.
//

import Foundation

class LoggedInUser: NSObject, Decodable {
    let token: String
    let user: User
}
