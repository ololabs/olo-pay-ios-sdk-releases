// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  MetadataGenerator.swift
//  OloPaySDK
//
//  Created by Richard Dowdy on 5/30/23.
//

import Foundation
import UIKit

class OPMetadataGenerator: NSObject {
    
    private var _source: OPPaymentMethodSource
    private var _applePayMerchantId: String? = nil
    private var _applePayCompanyLabel: String? = nil
    
    init (_ source: OPPaymentMethodSource) {
        _source = source
    }
    
    init (applePayMerchantId: String?, applePayCompanyLabel: String?) {
        _source = OPPaymentMethodSource.applePay
        _applePayMerchantId = applePayMerchantId
        _applePayCompanyLabel = applePayCompanyLabel
    }
    
    internal func generate() -> [String: String] {
        let buildType = OPSdkBuildType.convert(from: OPSdkBuild.buildType)
        
        var metadata: [String: String] = [
            OPMetadataStrings.creationSourceKey: _source.description,
            OPMetadataStrings.sdkBuildTypeKey: buildType?.description ?? OPMetadataStrings.unknownValue,
            OPMetadataStrings.sdkVersionKey: OPSdkVersion.version,
            OPMetadataStrings.sdkPlatformKey: OPMetadataStrings.sdkPlatformValue,
            OPMetadataStrings.iosApiVersionKey: UIDevice.current.systemVersion,
            OPMetadataStrings.sdkEnvironmentKey: OloPayAPI.environment.description,
        ]
        
        if let hybridInfo = OloPayAPI.sdkWrapperInfo {
            metadata[OPMetadataStrings.hybridSdkPlatformKey] = hybridInfo.platform
            metadata[OPMetadataStrings.hybridSdkVersionKey] = hybridInfo.version
            metadata[OPMetadataStrings.hybridSdkBuildTypeKey] = hybridInfo.buildType
        }
        
        if(_source == OPPaymentMethodSource.applePay){
            metadata[OPMetadataStrings.digitalWalletCompanyLabelKey] = _applePayCompanyLabel ?? ""
            metadata[OPMetadataStrings.applePayMerchantIdKey] = _applePayMerchantId ?? ""
        }
        
        return metadata
    }
}
