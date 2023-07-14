//
//  OPPaymentMethodSource.swift
//  OloPaySDK
//
//  Created by Richard Dowdy on 5/30/23.
//

import Foundation

public enum OPPaymentMethodSource: Int, CustomStringConvertible {
    
    case singleLineInput
    case formInput
    case applePay
    
    public var description: String {
        switch self {
        case .singleLineInput:
            return "SingleLineInput"
        case .formInput:
            return "FormInput"
        case .applePay:
            return "ApplePay"
        }
    }
}
