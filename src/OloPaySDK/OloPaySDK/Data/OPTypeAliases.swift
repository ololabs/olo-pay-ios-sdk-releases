// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPTypeAliases.swift
//  OloPaySDK
//
//  Created by Justin Anderson on 6/16/21.
//

import Foundation
import UIKit

/// An empty block, called with no arguments, returning nothing.
public typealias OPVoidBlock = () -> Void

/// A callback used to return an error during the ApplePay completion flow
/// - Parameters:
///   - error: The error that occurred when submitting an ApplePay payment method to Olo's Ordering API, or `nil` if no error occurred
public typealias OPApplePayCompletionBlock = (_ error: Error?) -> Void

/// A completion handler used when generating payment methods
///
/// - Parameters:
///   - paymentMethod: The payment method from the response. Will be `nil` if an error occurs.
///   - error: The error returned from the response, or nil if no error occurred.
public typealias OPPaymentMethodCompletionBlock = (_ paymentMethod: OPPaymentMethodProtocol?, _ error: Error?) -> Void

/// A completion handler used when generating CVV update tokens
///
/// - Parameters:
///   - token: The CVV Update token from the response. Will be `nil` if an error occurs
///   - error: The error returned from the response, or nil if no error occured
public typealias OPCvvTokenUpdateCompletionBlock = (_ token: OPCvvUpdateTokenProtocol?, _ error: Error?) -> Void

/// A block used for returning an image associated with the card brand parameter
/// - Parameters:
///   - cardBrand: The brand to get an image for
/// - Returns: An image associated with the given brand, or nil
public typealias OPCardBrandImageBlock = (_ cardBrand: OPCardBrand) -> UIImage?

/// A block used for returning an error message based on the current state of the Card control
/// - Parameters:
///     - cardState: A representation of the current state of the card input control
///     - cardBrand: The detected brand of the card number entered by the user
///     - ignoreUneditedFieldErrors: If true, only fields that have been edited should be considered when generating an error message. If false, all fields should be considered.
/// - Returns: An error message, or empty string if no message should be displayed
public typealias OPCardErrorMessageBlock = (_ cardState: NSDictionary, _ cardBrand: OPCardBrand, _ ignoreUneditedFieldErrors: Bool) -> String

/// A block used for returning an error message based on the current state of the CVV control
/// - Parameters:
///     - cvvFieldState: A representation of the current state of the CVV control
///     - ignoreUneditedFieldErrors: If true, only fields that have been edited should be considered when generating an error message. If false, all fields should be considered.
/// - Returns: An error message, or empty string if no message should be displayed
public typealias OPCvvErrorMessageBlock = (_ cvvFieldState: OPCardFieldStateProtocol, _ ignoreUneditedFieldErrors: Bool) -> String
