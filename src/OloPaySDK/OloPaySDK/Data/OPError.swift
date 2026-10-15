// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPErrors.swift
//  OloPaySDK
//
//  Created by Justin Anderson on 6/17/21.
//

import Foundation
import Stripe

/// Error class for all OloPay-pecific errors
///
/// Errors will come back as either `Error` or `NSError` instances. To get an instance of this class
/// just check that it is the correct type and cast to `OPError`.
/// ```
/// func someMethod(error: Error?) {
///     if let opError = error as? OPError {
///         //Do something with the error
///     }
/// }
/// ```
@objc public class OPError : NSError {
    /// Domain for all OPError instances
    @objc public static let oloPayDomain = "com.olo.olopay"
    
    /// Error type key for the `userInfo` property. This can be used to access the error type, but the `errorType` property exposes this information directly
    @objc public static let errorTypeKey = "\(oloPayDomain):ErrorType"
    
    /// Card error type key for the `userInfo` property. This can be used to access the card error type, but the `cardErrorType` property exposes this information directly
    /// - Important: This key only exists in the `userInfo` dictionary if the error represents a card error
    @objc public static let cardErrorTypeKey = "\(oloPayDomain):CardErrorType"
    
    /// Create an `OPError` instance for a card error. Useful for testing purposes
    /// - Parameters
    ///     - cardErrorType:    The type of card error
    ///     - description: The description for the error
    @objc public init(cardErrorType: OPCardErrorType, description: String) {
        var userInfo: [String : Any] = [:]

        userInfo[OPError.errorTypeKey] = OPErrorType.cardError
        userInfo[OPError.cardErrorTypeKey] = cardErrorType
        userInfo[NSLocalizedDescriptionKey] = description

        super.init(domain: OPError.oloPayDomain, code: OPErrorType.cardError.rawValue, userInfo: userInfo)
    }
    
    /// Create an `OPError` instance (other than card errors). Useful for testing purposes
    /// - Parameters:
    ///     - errorType:   The type of error
    ///     - description: The description for the error
    @objc public init(errorType: OPErrorType, description: String) {
        var userInfo: [String : Any] = [:]

        userInfo[OPError.errorTypeKey] = errorType
        userInfo[OPError.cardErrorTypeKey] = nil
        userInfo[NSLocalizedDescriptionKey] = description

        super.init(domain: OPError.oloPayDomain, code: errorType.rawValue, userInfo: userInfo)
    }

    private init(error: NSError) {
        var userInfo: [String: Any] = [:]
        
        if let errorCode = STPErrorCode.init(rawValue: error.code) {
            let opErrorCode = OPErrorType.convert(from: errorCode)
            userInfo[OPError.errorTypeKey] = opErrorCode
            
            if opErrorCode == .cardError {
                userInfo[NSLocalizedDescriptionKey] = error.userInfo[NSLocalizedDescriptionKey] ?? ""
            }
        }
        
        if let errorCodeRaw = error.userInfo[STPError.cardErrorCodeKey] as? String, let errorCode = STPCardErrorCode.init(rawValue: errorCodeRaw) {
            userInfo[OPError.cardErrorTypeKey] = OPCardErrorType.convert(from: errorCode)
        }
        
        super.init(domain: OPError.oloPayDomain, code: error.code, userInfo: userInfo)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    internal static func wrapIfNeeded(from error: NSError?) -> NSError? {
        guard let unwrappedError = error, unwrappedError.domain == STPError.stripeDomain else {
            return error
        }

        return OPError(error: unwrappedError)
    }
    
    /// The type of error
    public var errorType: OPErrorType { userInfo[OPError.errorTypeKey] as? OPErrorType ?? OPErrorType.generalError }

    /// If `errorType` is `OPCardErrorType.cardError`, this holds the type of error. For any other error type this is `nil`
    public var cardErrorType: OPCardErrorType? { userInfo[OPError.cardErrorTypeKey] as? OPCardErrorType ?? nil }
    
    /// If `errorType` is `OPCardErrorType.cardError`, this holds a user-friendly message that can be displayed to the user. For any other error type this is `nil`
    /// - Note: This is a convenience property that is functionally equivalent to using `localizedDescription`
    public var cardErrorMessage: String? { errorType == .cardError ? localizedDescription : nil }
}


