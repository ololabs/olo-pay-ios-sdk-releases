// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPValidStateChangedDelegate.swift
//  OloPaySDK
//
//  Created by Justin Anderson on 9/29/23.
//

import Foundation

protocol OPValidStateChangedDelegate: NSObjectProtocol {
    func validStateChanged(isValid: Bool)
}
