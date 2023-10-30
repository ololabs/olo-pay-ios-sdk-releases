// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  UITestingIdentifiers.swift
//  OloPaySDKTestHarness
//
//  Created by Justin Anderson on 8/18/21.
//

import Foundation

// NOTE: All Strings in this class must be unique. They are used for automated UI testing
class UITestingIdentifiers {
    class TestHarness {
        public static let navigationBar : String = "TestHarness.NavigationBar"
        public static let cardView : String = "TestHarness.CardView"
        public static let formView : String = "TestHarness.FormView"
        public static let logView : String = "TestHarness.LogView"
        public static let submitButton : String = "TestHarness.SubmitButton"
        public static let applePayButton : String = "TestHarness.ApplePayButton"
        public static let clearLogButton : String = "TestHarness.ClearLogButton"
        public static let settingsButton : String = "TestHarness.SettingsButton"
    }

    class Settings {
        public static let logCardInputToggle : String = "Settings.CardInputToggle"
        public static let completePaymentToggle : String = "Settings.CompletePaymentToggle"
        public static let apiUrlTextField : String = "Settings.ApiUrlTextField"
        public static let apiKeyTextField : String = "Settings.ApiKeyTextField"
        public static let restaurantIdTextField : String = "Settings.RestaurantIdTextField"
        public static let productIdTextField : String = "Settings.ProductIdTextField"
        public static let productQtyTextField : String = "Settings.ProductQtyTextField"
        public static let emailTextField : String = "Settings.EmailTextField"
        public static let navigationBar : String = "Settings.NavigationBar"
        public static let displayCardErrorsToggle : String = "Settings.DisplayCardErrorsToggle"
        public static let customCardErrorMessagesToggle : String = "Settings.CustomCardErrorMessagesToggle"
        public static let displayPostalCodeToggle : String = "Settings.DisplayPostalCodeToggle"
        public static let useCardViewPaymentToggle : String = "Settings.UseCardViewPaymentToggle"
        public static let useFormViewPaymentToggle : String = "Settings.UseFormViewPaymentToggle"
        public static let logFormValidToggle : String = "Settings.LogFormValidToggle"
        public static let doneButton : String = "Settings.DoneButton"
        public static let applePayBillingSchemeIdTextField : String = "Settings.ApplePayBillingSchemeIdTextField"
        public static let logCvvChangesToggle: String = "Settings.LogCvvChangesToggle"
        public static let displayCvvErrorsToggle: String = "Settings.DisplayCvvErrorsToggle"
        public static let customCvvErrorMessagesToggle: String = "Settings.CustomCvvErrorMessages"
    }
}
