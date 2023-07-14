//
//  MetadataGenerator.swift
//  OloPaySDK
//
//  Created by Richard Dowdy on 5/30/23.
//

import Foundation
import UIKit

public class OPMetadataGenerator: NSObject {
    
    private var _source: OPPaymentMethodSource
    
    init (_ source: OPPaymentMethodSource) {
        _source = source
    }
    
    func generate() -> [String: String] {
        var metadata: [String: String] = [
            OPMetadataStrings.creationSourceKey: _source.description,
            OPMetadataStrings.sdkBuildTypeKey: OPStorageWrapper.getPListValue(of: "SDK Build Type", from: "Info", as: String.self) ?? OPMetadataStrings.unknownValue,
            OPMetadataStrings.sdkVersionKey: OPStorageWrapper.getPListValue(of: "SDK Build Version", from: "Info", as: String.self) ?? OPMetadataStrings.unknownValue,
            OPMetadataStrings.sdkPlatformKey: OPMetadataStrings.sdkPlatformValue,
            OPMetadataStrings.iosApiVersionKey: UIDevice.current.systemVersion,
            OPMetadataStrings.sdkEnvironmentKey: OloPayAPI.environment.description,
            OPMetadataStrings.sdkFreshInstallKey: String(OloPayAPI.freshSetup),
        ]
        
        if let hybridInfo = OloPayAPI.sdkWrapperInfo {
            metadata[OPMetadataStrings.hybridSdkPlatformKey] = hybridInfo.platform
            metadata[OPMetadataStrings.hybridSdkVersionKey] = hybridInfo.version
            metadata[OPMetadataStrings.hybridSdkBuildTypeKey] = hybridInfo.buildType
        }
        
        if(_source == OPPaymentMethodSource.applePay){
            // TODO: Fill out when we work on ApplePay Metadata support OLO-56324
            metadata[OPMetadataStrings.applePayCountryCodeKey] = ""
            metadata[OPMetadataStrings.digitalWalletCompanyLabelKey] = ""
            metadata[OPMetadataStrings.applePayMerchantIdKey] = ""
        }
        
        return metadata
    }
}
