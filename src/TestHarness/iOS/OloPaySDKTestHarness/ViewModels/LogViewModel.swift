// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  LogViewModel.swift
//  OloPaySDKTestHarness
//
//  Created by Justin Anderson on 8/15/23.
//

import Foundation
import OloPaySDK

public protocol LogViewModelDelegate: NSObjectProtocol {
    func logTextChanged(_ logText: String)
}

public protocol LogViewModelProtocol: NSObjectProtocol {
    func clearLog()
    func log(_ message : String?, prependNewLine: Bool, appendNewLine: Bool)
    func logError(error: Error?)
    func logPaymentMethod(paymentMethod: OPPaymentMethodProtocol?)
}

class LogViewModel: NSObject, LogViewModelProtocol {
    private var _logText: String = ""
    
    weak var delegate: LogViewModelDelegate?
    
    public func clearLog() {
        _logText = ""
        delegate?.logTextChanged(_logText)
    }
    
    public func log(_ message : String?, prependNewLine: Bool = true, appendNewLine: Bool = true) {
        if (prependNewLine) {
            self._logText += "\n"
        }
        
        if let unwrappedMessage = message {
            self._logText += unwrappedMessage
        }
        
        if (appendNewLine) {
            self._logText += "\n"
        }
        
        delegate?.logTextChanged(_logText)
    }
    
    func logError(error: Error?) {
        guard let unwrappedError = error else {
            return
        }
        
        self.log(String(describing: unwrappedError as NSError))
        
        if let opError = unwrappedError as? OPError {
            self.log("OP Error Details:", appendNewLine: false)
            self.log("Error Type: \(opError.errorType)", appendNewLine: false)
            
            if let errorType = opError.cardErrorType {
                self.log("Card Error Type: \(errorType)", appendNewLine: false)
            } else {
                self.log("Card Error Type: nil", appendNewLine: false)
            }
            
            self.log("Card Error Message: \(opError.cardErrorMessage ?? "nil")")
        }
    }
    
    func logPaymentMethod(paymentMethod: OPPaymentMethodProtocol?) {
        guard let unwrappedPaymentMethod = paymentMethod else {
            self.log("Payment method not created")
            return
        }
        
        self.log(String(describing: unwrappedPaymentMethod))
    }
    
    func logCvvToken(token: OPCvvUpdateTokenProtocol?) {
        guard let unwrappedToken = token else {
            self.log("CVV token not created")
            return
        }
        
        self.log("CVV Token Created")
        self.log(String(describing: unwrappedToken))
    }
}
