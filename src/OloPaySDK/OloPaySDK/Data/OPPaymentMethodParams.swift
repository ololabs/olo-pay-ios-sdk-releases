// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPPaymentMethodParams.swift
//  OloPaySDK
//
//  Created by Kyle Szklenski on 9/1/21.
//

import Foundation
import Stripe

/// Protocol for mocking/testing purposes. See `OPPaymentMethodParams` dor documentation
@objc public protocol OPPaymentMethodParamsProtocol : NSObjectProtocol {}

/// Payment method parameters to send payment data to `OloPayAPI.createPaymentMethod(...)`
@objc public class OPPaymentMethodParams : NSObject, OPPaymentMethodParamsProtocol {
    private var _paymentMethodParams : STPPaymentMethodParams
    
    internal var paymentMethodParams: STPPaymentMethodParams {
        get { return _paymentMethodParams }
    }
    
    internal init(_ params : STPPaymentMethodParams) {
        _paymentMethodParams = params
    }
}
