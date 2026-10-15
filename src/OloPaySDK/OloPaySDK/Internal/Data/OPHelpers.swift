// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPHelpers.swift
//  OloPaySDK
//
//  Created by Justin Anderson on 6/16/21.
//

import Foundation

func dispatchToMainThreadIfNecessary(_ block: @escaping () -> Void) {
    if Thread.isMainThread {
        block()
    } else {
        DispatchQueue.main.async(execute: block)
    }
}
