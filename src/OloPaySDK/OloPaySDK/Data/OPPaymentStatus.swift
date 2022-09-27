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

/// An enum representing the status of a payment requested from the user.
@objc public enum OPPaymentStatus : Int, CustomStringConvertible {
    /// The payment succeeded.
    case success
    /// The payment failed due to an unforeseen error, such as the user's Internet connection being offline.
    case error
    /// The user cancelled the payment (for example, by hitting "cancel" in the Apple Pay dialog).
    case userCancellation

    /// A string representation of this enum
    public var description: String {
        switch self {
        case .success:
            return "Success"
        case .error:
            return "Error"
        case .userCancellation:
            return "UserCancellation"
        }
    }
    
    static func convert(from paymentStatus: STPPaymentStatus) -> OPPaymentStatus {
        switch paymentStatus {
        case .error:
            return OPPaymentStatus.error
        case .success:
            return OPPaymentStatus.success
        case .userCancellation:
            return OPPaymentStatus.userCancellation
        @unknown default:
            return OPPaymentStatus.error
        }
    }

    static func convert(from paymentStatus: OPPaymentStatus) -> STPPaymentStatus {
        switch paymentStatus {
        case .error:
            return STPPaymentStatus.error
        case .success:
            return STPPaymentStatus.success
        case .userCancellation:
            return STPPaymentStatus.userCancellation
        }
    }
}
