# Changelog

## v4.0.2 (Jun 20, 2024)

### Updates
- `OPPaymentCardDetailsView`: Add new property for setting alignment of the built in error message text
- `OPPaymentCardCvvView`: Add new property for setting alignment of the built in error message text
- `OPPaymentCardCvvView`: Fixed issue with text color not updating immediately after being set
- TestHarness: Fixed custom error message for invalid card numbers

### Bug Fixes
- Fixed crash on SDK initialization/setup

### Dependency Updates
- Updated to Stripe iOS v23.27.3
- Xcode 14 is [no longer supported by Apple](https://developer.apple.com/news/upcoming-requirements/?id=04292024a). Please upgrade to Xcode 15 or later.

## v4.0.1 (Mar 20, 2024)

### Updates
- Added Swift Package Manager Support
- Deprecated `OPSetupParameters.freshSetup`
- Added public getter for `OloPayAPI.environment`

#### Dependency Updates
- Updated to Stripe iOS v23.24.1

## v4.0.0 (Oct 27, 2023)

#### Breaking Changes
- `OloPayAPI`: Removed previously deprecated versions of `createPaymentMethod(...)`
- Changed all references of `CVC` to `CVV`
    - See: `OPCardErrorType`
    - See: `OPCardField`
    - See: `OPStrings`
- Removed `OPCardErrorType.incorrectNumber` and merged it's use case with `OPCardErrorType.invalidNumber`
- Removed `OPCardErrorType.incorrectZip` and merged it's use case with `OPCardErrorType.invalidZip`
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
- `OPApplePayContext`: General improvements to the Apple Pay flow
- `OPApplePayContextProtocol:` Added `presentApplePay(...)` overload that also takes a merchant id and company label as parameters
- `OPApplePayContext:` Added `presentApplePay(...)` overload that also takes a merchant id and company label as parameters
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
- `OPPaymentCardDetailsView`: Error message now displays if `getPaymentMethodParams()` is called and card details are invalid
- `OPPaymentCardDetailsView`: Added `hasErrorMessage(...)`
- `OPPaymentCardDetailsView`: Added `getErrorMessage(...)`
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
- `OloPayAPI`: Added safeguard to `createPaymentRequest(...)` for Apple Pay merchant id and company name
- `OloPayAPI`: : Added more robust retry mechanism in `createPaymentMethod(...)`
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
- `OloPayAPI`: Added `createPaymentMethod(...)` that takes an instance of `OPPaymentMethodParamsProtocol`
- `OloPayAPI`: Deprecated `createPaymentMethod(...)` that takes an instance of `OPPaymentCardDetailsForm`
- `OloPayAPI`: Deprecated `createPaymentMethod(...)` that takes an instance of `OPPaymentCardDetailsView`
- `OloPayAPI`: More robust error handling in `createPaymentMethod(...)`
- `OPPaymentCardDetailsView`: Added `expirationIsValid` convenience property
- `OPPaymentCardDetailsView`: Added `expirationIsEmpty` convenience property
- `OPPaymentCardDetailsView`: Added `postalCodeIsEmpty` convenience property
- `OPPaymentCardDetailsView`: Added ability to provide custom error messages via `errorMessageHandler` property
- `OPPaymentCardDetailsView`: Added ability to turn off display of error messages
- `OPPaymentCardDetailsView`: Added `errorMessage` property
- `OPPaymentCardDetailsView`: Added `getUserFacingMessage(...)` to get an error message for a specific field
- `OPPaymentCardDetailsView`: Added `getPaymentMethodParams(...)`

## 1.0.1 (Sep 24, 2021)

#### Updates
- `OPPaymentCardDetailsView`: `isValid` property now returns false if the card type isn't supported by Olo Pay
- `OPPaymentCardDetailsView`: New properties to check the validity of each card field
- `OloPayAPI`: `createPaymentMethod(...)` returns an error if the card type isn't supported by Olo Pay

## 1.0.0
- Initial release
