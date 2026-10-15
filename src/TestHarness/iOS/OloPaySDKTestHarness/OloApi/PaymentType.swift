// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  PaymentType.swift
//  OloPaySDKTestHarness
//
//  Created by Justin Anderson on 10/16/23.
//

import Foundation
import OloPaySDK

class PaymentType {
    let paymentMethod: OPPaymentMethodProtocol?
    let cvvToken: OPCvvUpdateTokenProtocol?
    
    init(_ paymentMethod: OPPaymentMethodProtocol) {
        self.paymentMethod = paymentMethod
        cvvToken = nil
    }
    
    init(_ cvvToken: OPCvvUpdateTokenProtocol) {
        self.cvvToken = cvvToken
        paymentMethod = nil
    }
}
