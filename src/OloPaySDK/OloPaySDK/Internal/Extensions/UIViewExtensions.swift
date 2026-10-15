// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  UIViewExtensions.swift
//  OloPaySDK
//
//  Created by Richard Dowdy on 7/24/24.
//

import Foundation
import UIKit

internal extension UIView {
    class func getAllTextFields(from parentView: UIView) -> [UITextField] {
        return parentView.subviews.flatMap { subView -> [UITextField] in
            var result = getAllTextFields(from: subView) as [UITextField]
            
            if let textField = subView as? UITextField {
                result.append(textField)
                return result
            }
            
            return result
        }
    }
}
