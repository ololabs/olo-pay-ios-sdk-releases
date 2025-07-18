# Changelog

## v5.2.1 (July 18, 2025)

### Updates
- `JCB`, `DinersClub`, and `UnionPay` cards are now accepted and treated as `Discover` cards

### Bug Fixes
- `OPApplePayLauncher`: Fixed bug causing `lineItemTotalMismatchError` to be thrown when an empty `lineItems` array was passed to the `present()` method
- `OPPaymentMethod`: Fixed bug causing phonetic name to not be set properly when using Apple Pay

## v5.2.0 (Apr 3, 2025)

### Updates
- Added `OPApplePayButton` as a convenience wrapper around `PKPaymentButton`

## v5.1.0 (Mar 7, 2025)

### Updates
- Support for Xcode 16
- `OPPaymentCardDetailsForm`: Updated constraints to be more flexible
- `OPApplePayLauncherError`: Added `unexpectedError` value

### Bug Fixes
- `OPApplePayLauncher`: Fixed bug that caused some error scenarios being improperly treated as timeout errors or a user cancellation

### Dependency Updates
- Updated to Stripe iOS v24.7.0 

## v5.0.0 (Feb 24, 2025)

### Overview
- Apple Pay overhaul
  - Removed Apple Pay configuration from SDK setup/initialization and move it to OPApplePayLauncher
  - Apple Pay sheet can be displayed multiple times from a single OPApplePayLauncher instance
  - Added support for timeout detection
  - Added support for line items
  - Renamed classes, properties, and functions for clarity
  - Added additional data specific to Apple Pay to payment methods
- Simplified SDK initialization

### Breaking Changes
- `OloPayAPI`
  - Removed `deviceSupportsApplePay()` in favor of `OPApplePayLauncher.canMakePayments()`
  - Removed `createPaymentRequest()`. Payment requests are now created by `OPApplePayLauncher` as needed
- `OloPayApiInitializer`: Changed `setup()` to take an `OPEnvironment` parameter instead of `OPSetupParameters`
- `OPApplePayContext`
  - Renamed to `OPApplePayLauncher`
  - Changed constructor to take an `OPApplePayConfiguration` parameter instead of a `PKPaymentRequest` parameter
  - Renamed `presentApplePay()` to `present()`
- `OPApplePayContextError` 
  - Renamed to `OPApplePayLauncherError`
  - Removed `missingMerchantId` value
  - Removed `missingCompanyLabel` value
- `OPApplePayContextDelegate`
  - Renamed to `OPApplePayLauncherDelegate`
  - Renamed `applePaymentMethodCreated()` to `paymentMethodCreated()` and changed method signature
  - Renamed `applePaymentCompleted()` to `applePayDismissed()` and changed method signature
- `OPApplePayContextProtocol`: Renamed to `OPApplePayLauncherProtocol`
- `OPPaymentStatus`: Renamed to `OPApplePayStatus`
- `OPSetupParameters`: Class removed
- `OPPaymentMethodProtocol`
  - Renamed `country` property to `countryCode`
  - The `last4` property is no longer nullable
  - The `postalCode` property is no longer nullable
  - The `countryCode` property is no longer nullable

### Updates
- New Classes/Enums
  - `OPAddressProtocol`
  - `OPApplePayConfiguration`
  - `OPCurrencyCode`
- `OPApplePayLauncher`
  - Apple Pay sheet can be presented multiple times from the same instance
  - Changed signatures of `present()` methods
  - Added `configuration` property
  - Added `delegate` proeprty
  - Added `canMakePayments()` method
- `OPApplePayLauncherError`
  - Added `configurationNotSet` value
  - Added `delegateNotSet` value
  - Added `invalidCountryCode` value
  - Added `applePayNotSupported` value
  - Added `lineItemTotalMismatchError` value
- `OPApplePayStatus`: Added `timeout` value
- `OPPaymentMethodProtocol`
  - Added `applePayCardDescription` property
  - Added `billingAddress` property
  - Added `email` property
  - Added `fullName` property
  - Added `fullPhoneticName` property
  - Added `phoneNumber` property

### Dependency Updates
- Updated to Stripe iOS v24.5.0

## v4.1.0 (Dec 3, 2024)

### Updates
- `OPPaymentCardDetailsView`: Added new `becomeFirstResponder` method to allow for setting a specific field as first reponder.
- `OPPaymentCardDetailsForm`: Added new `becomeFirstResponder` method to allow for setting a specific field as first reponder.
- `OPPaymentCardCvvView`: Added `intrinsicContentSize` to properly account for the error message size.

### Bug Fixes
- `OPPaymentCardDetailsView`: Fix `intrinsicContentSize` to properly account for the error message size.

### Dependency Updates
- Updated to Stripe iOS v24.1.0

## v4.0.3 (Oct 25, 2024)

### Bug Fixes
- Fix issue with SDK assets not loading properly when using Swift Package Manager

## v4.0.2 (Jun 20, 2024)

### Updates
- `OPPaymentCardDetailsView`: Add new property for setting alignment of the built in error message text
- `OPPaymentCardCvvView`
  - Add new property for setting alignment of the built in error message text
  - Fixed issue with text color not updating immediately after being set
- TestHarness: Fixed custom error message for invalid card numbers

### Bug Fixes
- Fixed crash on SDK initialization/setup

### Dependency Updates
- Updated to Stripe iOS v23.27.3
- Xcode 14 is [no longer supported by Apple](https://developer.apple.com/news/upcoming-requirements/?id=04292024a). Please upgrade to Xcode 15 or later.

## v4.0.1 (Mar 20, 2024)

### Updates
- Added Swift Package Manager Support
- `OPSetupParameters`: Deprecated `freshSetup` property
- `OloPayAPI`: Added public getter for `environment` property

#### Dependency Updates
- Updated to Stripe iOS v23.24.1

## v4.0.0 (Oct 27, 2023)

#### Breaking Changes
- `OloPayAPI`: Removed previously deprecated versions of `createPaymentMethod(...)`
- Changed all references of `CVC` to `CVV`
    - See: `OPCardErrorType`
    - See: `OPCardField`
    - See: `OPStrings`
- `OPCardErrorType`
  - Removed `incorrectNumber` property and merged it's use case with `invalidNumber`
  - Removed `incorrectZip` property and merged it's use case with `invalidZip`
- Changed the method signature of `OPCardErrorMessageBlock` 
    - See: `OPPaymentCardDetailsView.errorMessageHandler`
- `OPPaymentCardDetailsView`
    - `OPPaymentCardDetailsView.getPaymentMethodParams(...)` no longer throws an exception if card details are invalid and instead returns `nil` 

#### Updates
- Added support for CVV tokenization
    - See: new `OPPaymentCardCvvView` control
    - See: `OloPayAPI.createCvvUpdateToken(...)`
- Added new callback methods to delegates that do not contain a UI parameter to allow for better separation of UI and data layers
    - See: `OPPaymentCardDetailsFormDelegate`
    - See: `OPPaymentCardDetailsViewDelegate`
- Improved support for handling unsupported card brands
- Added `OPPaymentMethodProtocol.environment` property to know what environment was used to create a payment method
- `OPPaymentCardDetailsView`
    - Updated default error font to respect user's font scaling settings
    - Added `OPPaymentCardDetailsView.fieldStates` property (and `OPPaymentCardDetailsView.fieldStatesObjc` for Obj-c support)
    - Deprecated all properties that make use of `CVC` in favor of new ones that make use of `CVV`
    - Changed default placeholder for postal code field to "Postal Code" regardless of country setting
    - Improvded algorithm for detecting and displaying error messages to the user
- Test Harness Improvements
    - New tabbed interface for each main aspect of the Olo Pay SDK: Credit Cards, Apple Pay, CVV Tokenization
    - Updated to use MVVM architecture

#### Bug Fixes
- `OPPaymentCardDetailsForm`: Fixed bug in `becomeFirstResponder()` that prevented the control from becoming the first responder
- `OPPaymentCardDetailsView`
    - Fixed bug with error message displaying when calling `OPPaymentCardDetailsView.clear(...)`
    - Fixed bug preventing an error from displaying when pressing the back button on the keyboard

#### Dependency Updates
- Updated to Stripe iOS v23.17.2

## v3.0.0 (July 14, 2023)

#### Breaking Changes
- `OPApplePayContextProtocol:` Added `throws` to signature of `presentApplePay(...)`
- `OPApplePayContext:` Added `throws` to signature of `presentApplePay(...)`, which will now throw errors for an empty or missing merchant id or company label

#### Updates
- `OPApplePayContext`
  - General improvements to the Apple Pay flow
  - Added `presentApplePay(...)` overload that also takes a merchant id and company label as parameters
- `OPApplePayContextProtocol:` Added `presentApplePay(...)` overload that also takes a merchant id and company label as parameters
- `OPApplePayContextError:` Added `emptyCompanyLabel` and `emptyMerchantId` enum values

## v2.1.6 (Jun 16, 2023)

#### Updates 
- Improved caching mechanism when switching between Test and Production environments during development
- Fix incorrect title for CocoaPods Setup documentation

#### Dependency Updates
- Updated to Stripe iOS v23.9.0

## v2.1.5 (Dec 9, 2022)

#### Bug Fixes
- Fixed bug with CocoaPods referencing an older version of Stripe iOS SDK

## v2.1.4 (Dec 5, 2022)

#### Updates
- Reverted Podspec back use https instead of ssh (as recommended by CocoaPods)
- Updated CocoaPods, Carthage, and Manual setup documentation

#### Dependency Updates
- Updated to Stripe iOS v23.2.0 (see updated setup instructions)

## v2.1.3 (Nov 15, 2022)

#### Updates
- Fixed typo in podspec source url

## v2.1.2 (Nov 15, 2022)

#### Updates
- Changed Podspec to use ssh instead of https
- Fixed missing setup guides in documentation

## v2.1.1 (Nov 9, 2022)

#### Updates
- Added missing podspec file to fix CocoaPods usage
- Updated Carthage usage guide with proper tag syntax

## v2.1.0 (Nov 7, 2022)

#### Breaking Changes
- Added Carthage support (Note: Build path of Stripe dependencies changed)

#### Updates
- Added CocoaPods support
- `OPPaymentCardDetailsView`: Add US and CA postal code validation

## v2.0.0 (Sep 27, 2022)

#### Breaking Changes
- Removed `OloPaySDK-Dev` target
- Added `OPEnvironment` enum
- `OPSetupParams`: Added environment parameter and reordered existing parameters

#### Bug Fixes
- Fixed Xcode 14 compilation error
- `OPPaymentCardDetailsView`: Fixed postal code error message displaying when it shouldn't

#### Dependency Updates
- Update to Stripe iOS v22.8.1

## v1.2.1 (May 18, 2022)

#### Bug Fixes
- Fixed typo in error message for empty CVC fields
- Fixed test harness incorrectly logging whether the `OPPaymentCardDetailsForm` is valid or not

#### Updates
- `OPPaymentCardDetailsView`
  - Error message now displays if `getPaymentMethodParams()` is called and card details are invalid
  - Added `hasErrorMessage(...)`
  - Added `getErrorMessage(...)`
- `OPCardBrand`: Added `unsupported` value
- Updated card error messages to distinguish between invalid card numbers and unsupported card numbers
- Added "Log Form Valid Changes" option to Test Harness settings
- Removed Carthage files to reduce SDK download size

## 1.2.0 (Feb 28, 2022)

#### Bug Fixes
- Fixes for hybrid app solutions (e.g. React Native)
- Test Harness compilation fixes after updating Stripe SDK

#### Updates
- Official React Native bridging files support
- Added SDK setup steps to documentation

#### Dependency Updates
- Update to Stripe iOS v21.12.0

## 1.1.3 (Dec 17, 2021)

#### Updates
- `OloPayAPI`: 
  - Added safeguard to `createPaymentRequest(...)` for Apple Pay merchant id and company name
  - Added more robust retry mechanism in `createPaymentMethod(...)`
- `OloPayApiInitializer`: Added completion handler to `setup(...)`
- `OPError`: Added public constructor
- `OPPaymentMethod`: Added `country` property
- `OPPaymentMethodProtocol`: Added `country` property
- Added unit tests

## 1.1.2 (Oct 22, 2021)

#### Updates
- Minor Xcode project tweaks

## 1.1.1 (Oct 22, 2021)

#### Updates
- Minor Xcode project tweaks

## 1.1.0 (Oct 21, 2021)

#### Breaking Changes
- Removed `OloPayAPIGateway` (`OloPayAPI` should now be used directly)
- `OloPayAPI`: Removed `setup()` method
- `OloPayApiInitializer`: Added `setup()` method

#### Bug Fixes
- Fixed issue with Carthage always pulling the latest version of the Stripe SDK
- `OPPaymentCardDetailsView`: Added missing `@objc` annotations

#### Updates
- Added missing documentation
- New Classes/Protocols/Enums
  - Added `OloPayApiInitializer`
  - Added `OloPayAPIProtocol`
  - Added `OPPaymentCardDetailsForm`
  - Added `OPPaymentMethodProtocol`
  - Added `OPPaymentMethodParams`
  - Added `OPPaymentMethodParamsProtocol`
  - Added `OPPaymentCardDetailsForm`
  - Added `OPCardFormStyle`
  - Added `OPStrings`    
- `OloPayAPI`
  - Added `createPaymentMethod(...)` that takes an instance of `OPPaymentMethodParamsProtocol`
  - Deprecated `createPaymentMethod(...)` that takes an instance of `OPPaymentCardDetailsForm`
  - Deprecated `createPaymentMethod(...)` that takes an instance of `OPPaymentCardDetailsView`
  - More robust error handling in `createPaymentMethod(...)`
- `OPPaymentCardDetailsView`: 
  - Added `expirationIsValid` convenience property
  - Added `expirationIsEmpty` convenience property
  - Added `postalCodeIsEmpty` convenience property
  - Added ability to provide custom error messages via `errorMessageHandler` property
  - Added ability to turn off display of error messages
  - Added `errorMessage` property
  - Added `getUserFacingMessage(...)` to get an error message for a specific field
  - Added `getPaymentMethodParams(...)`

## 1.0.1 (Sep 24, 2021)

#### Updates
- `OPPaymentCardDetailsView`
  - `isValid` property now returns false if the card type isn't supported by Olo Pay
  - New properties to check the validity of each card field
- `OloPayAPI`: `createPaymentMethod(...)` returns an error if the card type isn't supported by Olo Pay

## 1.0.0
- Initial release
