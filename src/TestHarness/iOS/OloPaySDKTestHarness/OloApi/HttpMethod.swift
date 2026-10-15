// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  HttpMethod.swift
//  OloPaySDKTestHarness
//
//  Created by Justin Anderson on 7/9/21.
//

import Foundation

public enum HttpMethod : Int, CustomStringConvertible {
    case get
    case post
    case put
    case delete
    
    public var description: String {
        switch self {
        case .get:
            return "GET"
        case .post:
            return "POST"
        case .put:
            return "PUT"
        case .delete:
            return "DELETE"
        }
    }
}
