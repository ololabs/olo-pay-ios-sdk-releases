// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPPaymentMethodParams.swift
//  OloPaySDK
//
//  Created by Justin Anderson on 9/11/23.
//

import Foundation
import Stripe

class OPPaymentMethodParams : NSObject, OPPaymentMethodParamsProtocol {
    private var _paymentMethodParams : STPPaymentMethodParams
    
    internal var paymentMethodParams: STPPaymentMethodParams {
        get { return _paymentMethodParams }
    }
    
    internal init(_ paymentMethodParams : STPPaymentMethodParams, fromSource source: OPPaymentMethodSource) {
        _paymentMethodParams = paymentMethodParams
        let _metadataGenerator = OPMetadataGenerator(source)
        _paymentMethodParams.metadata = _metadataGenerator.generate()
    }
}
