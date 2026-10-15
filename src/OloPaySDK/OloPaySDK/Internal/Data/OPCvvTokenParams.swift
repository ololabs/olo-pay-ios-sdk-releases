// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPCvvTokenParams.swift
//  OloPaySDK
//
//  Created by Justin Anderson on 9/11/23.
//

import Foundation

class OPCvvTokenParams : NSObject, OPCvvTokenParamsProtocol {
    private let _cvv: String
    
    internal var cvv: String {
        get { return _cvv }
    }
    
    internal init(_ cvv: String) {
        _cvv = cvv
    }
}
