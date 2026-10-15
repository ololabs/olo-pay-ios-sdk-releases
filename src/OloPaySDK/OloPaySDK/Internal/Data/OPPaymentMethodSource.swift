// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPPaymentMethodSource.swift
//  OloPaySDK
//
//  Created by Richard Dowdy on 5/30/23.
//

import Foundation

enum OPPaymentMethodSource: Int, CustomStringConvertible {
    
    case singleLineInput
    case formInput
    case applePay
    
    public var description: String {
        switch self {
        case .singleLineInput:
            return "singleLineInput"
        case .formInput:
            return "formInput"
        case .applePay:
            return "applePay"
        }
    }
}
