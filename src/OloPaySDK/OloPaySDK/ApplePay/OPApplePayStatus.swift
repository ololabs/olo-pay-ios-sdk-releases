// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPPaymentStatus.swift
//  OloPaySDK
//
//  Created by Justin Anderson on 6/16/21.
//

import Foundation
import Stripe

/// An enum representing the status of an Apple Pay payment requested from the user.
@objc public enum OPApplePayStatus : Int, CustomStringConvertible {
    /// The payment succeeded.
    case success
    /// The payment failed due to an unforeseen error, such as the user's Internet connection being offline.
    case error
    /// The user cancelled the payment (for example, by hitting "cancel" in the Apple Pay dialog).
    case userCancellation
    /// The payment took too long and was canceled by Apple
    case timeout

    /// A string representation of this enum
    public var description: String {
        switch self {
        case .success:
            return "Success"
        case .error:
            return "Error"
        case .userCancellation:
            return "UserCancellation"
        case .timeout:
            return "Timeout"
        }
    }
    
    static func convert(from paymentStatus: STPPaymentStatus) -> OPApplePayStatus {
        switch paymentStatus {
        case .error:
            return OPApplePayStatus.error
        case .success:
            return OPApplePayStatus.success
        case .userCancellation:
            return OPApplePayStatus.userCancellation
        @unknown default:
            return OPApplePayStatus.error
        }
    }

    static func convert(from paymentStatus: OPApplePayStatus) -> STPPaymentStatus {
        switch paymentStatus {
        case .error:
            return STPPaymentStatus.error
        case .success:
            return STPPaymentStatus.success
        case .userCancellation:
            return STPPaymentStatus.userCancellation
        case .timeout:
            return STPPaymentStatus.userCancellation //Stripe doesn't account for this scenario... this is the most similar status
        }
    }
}
