// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  ViewController.swift
//  OloPaySDKTestHarness
//
//  Created by Justin Anderson on 8/11/23.
//

import Foundation
import UIKit
import OloPaySDK

protocol ViewControllerWithSettingsProtocol : NSObjectProtocol {
    func settingsClicked()
}

class MainViewController: UITabBarController, UITabBarControllerDelegate {
    lazy var _logoItem: UIBarButtonItem = {
        let logoImage = UIImage.init(named: "OloPayLogo")
        let logoImageView = UIImageView.init(image: logoImage)
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        logoImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        let appName = UILabel()
        appName.font = UIFont.boldSystemFont(ofSize: 18)
        appName.text = "Olo Pay"
        appName.sizeToFit()
        
        let logoStack = UIStackView(arrangedSubviews: [logoImageView, appName])
        logoStack.axis = .horizontal
        logoStack.isLayoutMarginsRelativeArrangement = true
        logoStack.distribution = .equalSpacing
        logoStack.alignment = .fill
        
        return UIBarButtonItem(customView: logoStack)
    }()
    
    private let _oloPayApi = OloPayAPI()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.view.backgroundColor = UIColor.systemGray6
        self.navigationItem.leftBarButtonItem = _logoItem
        
        createTabBarController()
    }
    
    private func createTabBarController() {
        let settings = TestHarnessSettings.sharedInstance
        
        let cardInputViewModel = CardInputViewModel(logViewModel: LogViewModel(), settings: settings, oloPayApi: _oloPayApi)
        let cardInputTab = CardInputViewController(viewModel: cardInputViewModel)
        cardInputTab.title = "Credit Card"
        cardInputTab.tabBarItem.image = UIImage(systemName: "creditcard")
        
        let applePayViewModel = ApplePayViewModel(logViewModel: LogViewModel(), settings: settings, oloPayApi: _oloPayApi)
        let applePayTab = ApplePayViewController(viewModel: applePayViewModel)
        applePayTab.title = "Apple Pay"
        applePayTab.tabBarItem.image = UIImage(systemName: "apple.logo")
        
        let cvvTokenViewModel = CvvTokenViewModel(logViewModel: LogViewModel(), settings: settings, oloPayApi: _oloPayApi)
        let cvvTab = CvvTokenViewController(viewModel: cvvTokenViewModel)
        cvvTab.title = "CVV"
        cvvTab.tabBarItem.image = UIImage(systemName: "creditcard.and.123")
        
        self.viewControllers = [cardInputTab, applePayTab, cvvTab]
        self.tabBar.backgroundColor = UIColor.systemGray5
        
        tabBarController(self, didSelect: cardInputTab)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        self.navigationItem.title = viewController.title
        
        guard viewController is ViewControllerWithSettingsProtocol else {
            self.navigationItem.rightBarButtonItem = nil
            return
        }
        
        let settingsButton = UIBarButtonItem(title: "Settings", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.settingsClicked))
        settingsButton.accessibilityIdentifier = UITestingIdentifiers.TestHarness.settingsButton
        self.navigationItem.rightBarButtonItem = settingsButton
    }
    
    @objc func settingsClicked() {
        guard let settingsViewController = self.selectedViewController as? ViewControllerWithSettingsProtocol else {
            return
        }
        
        settingsViewController.settingsClicked()
    }
}
