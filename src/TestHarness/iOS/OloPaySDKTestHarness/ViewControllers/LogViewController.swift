// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  LogViewController.swift
//  OloPaySDKTestHarness
//
//  Created by Justin Anderson on 8/11/23.
//

import Foundation
import UIKit
import OloPaySDK

class LogViewController: UIViewController, LogViewModelDelegate {
    let _viewModel: LogViewModel
    
    let _logTitle = UILabel()
    let _logView = UITextView()
    let _clearButton = UIButton()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(viewModel: LogViewModel) {
        _viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        _viewModel.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.autoresizingMask = .flexibleHeight
        
        _logTitle.text = "Output Log"
        
        _logView.textColor = .label
        _logView.backgroundColor = UIColor.systemGray4
        _logView.isEditable = false
        _logView.accessibilityIdentifier = UITestingIdentifiers.TestHarness.logView
        
        _clearButton.setTitle("Clear Log", for: .normal)
        _clearButton.backgroundColor = .white
        _clearButton.addTarget(self, action: #selector(clearLog), for: .touchUpInside)
        _clearButton.accessibilityIdentifier = UITestingIdentifiers.TestHarness.clearLogButton
        _clearButton.layer.borderWidth = 2
        _clearButton.layer.borderColor = UIColor.systemBlue.cgColor
        _clearButton.setTitleColor(UIColor.systemBlue, for: .normal)
        _clearButton.setTitleColor(UIColor.darkGray, for: .disabled)
        
        let positiveViewSpacing: CGFloat = 10.0
        
        let mainStack = UIStackView(arrangedSubviews: [_logTitle, _logView, _clearButton])
        mainStack.axis = .vertical
        mainStack.distribution = .fill
        mainStack.alignment = .fill
        mainStack.spacing = positiveViewSpacing
        
        view.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            mainStack.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 1.0),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainStack.bottomAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.bottomAnchor, multiplier: 1.0),
            
            _logTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            _logTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            
            _logView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            _logView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            _logView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
            
            _clearButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            _clearButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func logTextChanged(_ logText: String) {
        dispatchToMainThreadIfNecessary {
            self._logView.text = logText
            
            // Auto-scroll to end
            let bottom = NSMakeRange(self._logView.text.count - 1, 1)
            self._logView.scrollRangeToVisible(bottom)
        }
    }
    
    @objc func clearLog() { _viewModel.clearLog() }
}
