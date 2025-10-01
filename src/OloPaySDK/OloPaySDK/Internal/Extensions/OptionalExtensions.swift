// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OptionalExtensions.swift
//  OloPaySDK
//
//  Created by Honz Williams on 7/16/25.
//

extension Optional where Wrapped: Collection {
  var isNilOrEmpty: Bool {
    switch self {
    case .none:
      return true
    case .some(let collection):
      return collection.isEmpty
    }
  }
}
