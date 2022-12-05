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
///   - error: The error that occurred when submitting an ApplePay payment method to Olo's Ordering API, or nil if no error occurred
public typealias OPApplePayCompletionBlock = (_ error: Error?) -> Void

/// A callback to be run with a PaymentMethod response from the OloPay API.
///
/// - Parameters:
///   - paymentMethod: The Olo Pay PaymentMethod from the response. Will be nil if an error occurs.
///   - error: The error returned from the response, or nil if none occurs.
public typealias OPPaymentMethodCompletionBlock = (_ paymentMethod: OPPaymentMethodProtocol?, _ error: Error?) -> Void

/// A block used for returning an image associated with the card brand parameter
/// - Parameters:
///   - cardBrand: The brand to get an image for
/// - Returns: An image associated with the given brand, or nil
public typealias OPCardBrandImageBlock = (_ cardBrand: OPCardBrand) -> UIImage?

/// A block used for returning an error message based on the current state of the passed-in card control
/// - Parameters:
///     - card: The card control
///     - field: The field that is invalid, or nil if a general error message should be displayed
/// - Returns: An error message, or nil if no message should be displayed
public typealias OPCardErrorMessageBlock = (_ card: OPPaymentCardDetailsView, _ field: OPCardField) -> String
