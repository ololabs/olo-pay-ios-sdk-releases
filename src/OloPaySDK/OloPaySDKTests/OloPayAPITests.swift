// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OloPayAPITests.swift
//  OloPaySDKTests
//
//  Created by Justin Anderson on 11/18/21.
//

import XCTest
import Stripe
@testable import OloPaySDK

class OloPayAPITests: XCTestCase {
    lazy var initializer: OloPayApiInitializer? = nil;
    let maxWaitSeconds: Double = 5
    
    override func setUpWithError() throws {
        initializer = OloPayApiInitializer();
    }

    override func tearDownWithError() throws {
    }

    func testCreatePaymentMethod_apiInitialized_invalidPublishableKey_updatesKey() throws {
        initializer!.setup(with: OPSetupParameters(withEnvironment: OPEnvironment.test, withFreshSetup: true))
        OloPayAPI.publishableKey = "foobar" //Reset the publishable key to an invalid one
        
        let expectation = XCTestExpectation(description: "createPaymentMethod() completed")
        OloPayAPI().createPaymentMethod(with: PaymentMethodParamsHelper.createValid()) { paymentMethod, error in
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: maxWaitSeconds)
        XCTAssertNotEqual("foobar", OloPayAPI.publishableKey) //Make sure the publishable key it NOT what we set it to after initializing the API
    }

    func testCreatePaymentMethod_paymentParamsInvalid_throwsUnknownCardError() throws {
        let expectation = XCTestExpectation(description: "createPaymentMethod() completed")
        OloPayAPI().createPaymentMethod(with: InvalidPaymentMethodParams()) { paymentMethod, error in
            guard let cardError = error as? OPError else {
                XCTFail("Error not thrown")
                expectation.fulfill()
                return
            }
            
            XCTAssertEqual(OPErrorType.cardError, cardError.errorType)
            XCTAssertEqual(OPCardErrorType.unknownCardError, cardError.cardErrorType)
            XCTAssertEqual(OPStrings.unsupportedCardError, cardError.cardErrorMessage)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: maxWaitSeconds)
    }
    
    func testCreatePaymentMethod_apiInitialized_paymentParamsValid_returnsValidPaymentMethod() throws {
        initializer!.setup(with: OPSetupParameters(withEnvironment: OPEnvironment.test, withFreshSetup: true))
        
        let expectation = XCTestExpectation(description: "createPaymentMethod() completed")
        OloPayAPI().createPaymentMethod(with: PaymentMethodParamsHelper.createValid()) { paymentMethod, error in
            guard (error as? OPError) == nil else {
                XCTFail("Error incorrectly thrown")
                expectation.fulfill()
                return
            }
            
            guard let paymentMethod = paymentMethod as? OPPaymentMethod else {
                XCTFail("Payment method not created")
                expectation.fulfill()
                return
            }
            
            XCTAssertEqual("4242", paymentMethod.last4)
            XCTAssertEqual(PaymentMethodParamsHelper.validExpYear, UInt(truncating: paymentMethod.expirationYear!))
            XCTAssertEqual(PaymentMethodParamsHelper.validExpMonth, UInt(truncating: paymentMethod.expirationMonth!))
            XCTAssertEqual(PaymentMethodParamsHelper.validPostalCode, paymentMethod.postalCode)
            XCTAssertFalse(paymentMethod.isApplePay)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: maxWaitSeconds)
    }
    
    func testCreatePaymentMethod_apiInitialized_paymentParamsInvalidNumber_throwsException() throws {
        let expectation = XCTestExpectation(description: "createPaymentMethod() completed")
        
        OloPayAPI().createPaymentMethod(with: PaymentMethodParamsHelper.createWithInvalidNumber()) { paymentMethod, error in
            guard let cardError = error as? OPError else {
                XCTFail("Error not thrown")
                expectation.fulfill()
                return
            }
            
            XCTAssertEqual(OPErrorType.cardError, cardError.errorType)
            XCTAssertEqual(OPCardErrorType.incorrectNumber, cardError.cardErrorType)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: maxWaitSeconds)
    }
    
    func testCreatePaymentMethod_apiInitialized_paymentParamsInvalidYear_throwsException() throws {
        let expectation = XCTestExpectation(description: "createPaymentMethod() completed")
        
        OloPayAPI().createPaymentMethod(with: PaymentMethodParamsHelper.createWithInvalidYear()) { paymentMethod, error in
            guard let cardError = error as? OPError else {
                XCTFail("Error not thrown")
                expectation.fulfill()
                return
            }
            
            XCTAssertEqual(OPErrorType.cardError, cardError.errorType)
            XCTAssertEqual(OPCardErrorType.invalidExpYear, cardError.cardErrorType)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: maxWaitSeconds)
    }
    
    func testCreatePaymentMethod_apiInitialized_paymentParamsInvalidMonth_throwsException() throws {
        let expectation = XCTestExpectation(description: "createPaymentMethod() completed")
        
        OloPayAPI().createPaymentMethod(with: PaymentMethodParamsHelper.createWithInvalidMonth()) { paymentMethod, error in
            guard let cardError = error as? OPError else {
                XCTFail("Error not thrown")
                expectation.fulfill()
                return
            }
            
            XCTAssertEqual(OPErrorType.cardError, cardError.errorType)
            XCTAssertEqual(OPCardErrorType.invalidExpMonth, cardError.cardErrorType)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: maxWaitSeconds)
    }
    
    func testCreatePaymentMethod_apiInitialized_paymentParamsInvalidCvc_throwsException() throws {
        let expectation = XCTestExpectation(description: "createPaymentMethod() completed")
        
        OloPayAPI().createPaymentMethod(with: PaymentMethodParamsHelper.createWithInvalidCvc()) { paymentMethod, error in
            guard let cardError = error as? OPError else {
                XCTFail("Error not thrown")
                expectation.fulfill()
                return
            }
            
            XCTAssertEqual(OPErrorType.cardError, cardError.errorType)
            XCTAssertEqual(OPCardErrorType.invalidCVC, cardError.cardErrorType)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: maxWaitSeconds)
    }
    
    func testCreatePaymentMethod_apiInitialized_paymentParamsUnsupportedCardBrand_throwsException() throws {
        let expectation = XCTestExpectation(description: "createPaymentMethod() completed")
        
        OloPayAPI().createPaymentMethod(with: PaymentMethodParamsHelper.createWithUnsupportedCardBrand()) { paymentMethod, error in
            guard let cardError = error as? OPError else {
                XCTFail("Error not thrown")
                expectation.fulfill()
                return
            }
            
            XCTAssertEqual(OPErrorType.cardError, cardError.errorType)
            XCTAssertEqual(OPCardErrorType.invalidNumber, cardError.cardErrorType)
            XCTAssertEqual(OPStrings.unsupportedCardError, cardError.cardErrorMessage)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: maxWaitSeconds)
    }
    
    func testCreatePaymentRequest_merchantIdNotSet_throwsMissingMerchantIdError() throws {
        initializer!.setup(with: OPSetupParameters(withEnvironment: OPEnvironment.test, withFreshSetup: true))
        do {
            let _ = try OloPayAPI().createPaymentRequest(forAmount: 2.50)
        } catch OPApplePayContextError.missingMerchantId {
            return //Exception thrown
        }
        
        XCTFail("missingMerchantId not thrown")
    }
    
    func testCreatePaymentRequest_companyNotSet_throwsMissingCompanyLabelError() throws {
        initializer!.setup(with: OPSetupParameters(withEnvironment: OPEnvironment.test, withFreshSetup: true, withApplePayMerchantId: "com.olopay.tests"))
        do {
            let _ = try OloPayAPI().createPaymentRequest(forAmount: 2.50)
        } catch OPApplePayContextError.missingCompanyLabel {
            return //Exception thrown
        }
        
        XCTFail("missingCompanyLabel not thrown")
    }
    
    func testUpdatePublishableKey_storesKey() throws {
        initializer!.setup(with: OPSetupParameters(withEnvironment: OPEnvironment.test, withFreshSetup: true))
        OloPayAPI.publishableKey = ""
        
        let expectation = XCTestExpectation(description: "updatePublishableKey() completed")
        OloPayAPI.updatePublishableKey {
            XCTAssertFalse(OloPayAPI.publishableKey.isEmpty)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: maxWaitSeconds)
    }
    
    private class InvalidPaymentMethodParams : NSObject, OPPaymentMethodParamsProtocol {
    }
    
    private class PaymentMethodParamsHelper {
        static let validCardNumber = "4242424242424242"
        static let invalidCardNumber = "1234567890123456"
        static let diningClubCardNumber = "3056930009020004"
        static let validExpYear: UInt = 2025
        static let invalidExpYear: UInt = 2020
        static let validExpMonth: UInt = 12
        static let invalidExpMonth: UInt = 24
        static let validCvc = "234"
        static let invalidCvc = "12"
        static let validPostalCode = "10004"
        
        static func createValid() -> OPPaymentMethodParams {
            return OPPaymentMethodParams(createStripePaymentMethod(), fromSource: OPPaymentMethodSource.singleLineInput)
        }
        
        static func createWithInvalidNumber() -> OPPaymentMethodParams {
            let paymentMethod = createStripePaymentMethod()
            paymentMethod.card?.number = invalidCardNumber
            return OPPaymentMethodParams(paymentMethod, fromSource: OPPaymentMethodSource.singleLineInput)
        }
        
        static func createWithInvalidYear() -> OPPaymentMethodParams {
            let paymentMethod = createStripePaymentMethod()
            paymentMethod.card?.expYear = NSNumber(value: invalidExpYear)
            return OPPaymentMethodParams(paymentMethod, fromSource: OPPaymentMethodSource.singleLineInput)
        }
        
        static func createWithInvalidMonth() -> OPPaymentMethodParams {
            let paymentMethod = createStripePaymentMethod()
            paymentMethod.card?.expMonth = NSNumber(value: invalidExpMonth)
            return OPPaymentMethodParams(paymentMethod, fromSource: OPPaymentMethodSource.singleLineInput)
        }
        
        static func createWithInvalidCvc() -> OPPaymentMethodParams {
            let paymentMethod = createStripePaymentMethod()
            paymentMethod.card?.cvc = invalidCvc
            return OPPaymentMethodParams(paymentMethod, fromSource: OPPaymentMethodSource.singleLineInput)
        }
        
        static func createWithUnsupportedCardBrand() -> OPPaymentMethodParams {
            let paymentMethod = createStripePaymentMethod()
            paymentMethod.card?.number = diningClubCardNumber
            return OPPaymentMethodParams(paymentMethod, fromSource: OPPaymentMethodSource.singleLineInput)
        }
        
        static func createStripePaymentMethod() -> STPPaymentMethodParams {
            let cardParams = STPCardParams()
            cardParams.number = validCardNumber
            cardParams.expYear = validExpYear
            cardParams.expMonth = validExpMonth
            cardParams.cvc = validCvc
            
            let paymentMethodParams = STPPaymentMethodParams()
            paymentMethodParams.card = STPPaymentMethodCardParams(cardSourceParams: cardParams)
            paymentMethodParams.type = .card
            
            let address = STPPaymentMethodAddress()
            address.postalCode = validPostalCode
            
            let billingDetails = STPPaymentMethodBillingDetails()
            billingDetails.address = address
            
            paymentMethodParams.billingDetails = billingDetails
            return paymentMethodParams
        }
    }
}
