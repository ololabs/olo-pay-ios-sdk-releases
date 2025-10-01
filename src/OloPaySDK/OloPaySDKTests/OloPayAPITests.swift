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
        let expectation = XCTestExpectation(description: "createPaymentMethod() completed")
        
        initializer!.setup(for: .test) {
            OloPayAPI.publishableKey = "foobar" //Reset the publishable key to an invalid one
            
            OloPayAPI().createPaymentMethod(with: PaymentMethodParamsHelper.createValid()) { paymentMethod, error in
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: maxWaitSeconds)
        XCTAssertNotEqual("foobar", OloPayAPI.publishableKey) //Make sure the publishable key it NOT what we set it to after initializing the API
    }

    func testCreatePaymentMethod_incorrectPaymentParamsType_throwsUnknownCardError() throws {
        let expectation = XCTestExpectation(description: "createPaymentMethod() completed")
        
        var paymentMethod: OPPaymentMethodProtocol? = nil
        var error: Error? = nil
        
        OloPayAPI().createPaymentMethod(with: InvalidPaymentMethodParams()) { pm, e in
            paymentMethod = pm
            error = e
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: maxWaitSeconds)
        
        guard let cardError = error as? OPError else {
            XCTFail("Expected error of type OPError")
            return
        }
        
        XCTAssertEqual(OPErrorType.cardError, cardError.errorType)
        XCTAssertEqual(OPCardErrorType.unknownCardError, cardError.cardErrorType)
        XCTAssertEqual(OPStrings.generalCardError, cardError.cardErrorMessage)
        XCTAssertNil(paymentMethod)
        
    }
    
    func testCreatePaymentMethod_apiInitialized_crossBrandPaymentParams_returnsValidPaymentMethod() throws {
        let expectation = XCTestExpectation(description: "createPaymentMethod() completed")
        
        var paymentMethod: OPPaymentMethodProtocol? = nil
        var error: Error? = nil
        
        initializer!.setup(for: .test) {
            OloPayAPI().createPaymentMethod(with: PaymentMethodParamsHelper.createValidWithCrossBrandCard()) { pm, e in
                paymentMethod = pm
                error = e
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: maxWaitSeconds)
        
        guard error == nil else {
            XCTFail("Error incorrectly thrown")
            return
        }
        
        guard let paymentMethod = paymentMethod as? OPPaymentMethod else {
            XCTFail("Payment method not created")
            return
        }
        
        XCTAssertEqual("0004", paymentMethod.last4)
        XCTAssertEqual(PaymentMethodParamsHelper.validExpYear, UInt(truncating: paymentMethod.expirationYear!))
        XCTAssertEqual(PaymentMethodParamsHelper.validExpMonth, UInt(truncating: paymentMethod.expirationMonth!))
        XCTAssertEqual(PaymentMethodParamsHelper.validPostalCode, paymentMethod.postalCode)
        XCTAssertEqual(OPCardBrand.discover, paymentMethod.cardType)
        XCTAssertFalse(paymentMethod.isApplePay)
    }
    
    func testCreatePaymentMethod_apiInitialized_paymentParamsValid_returnsValidPaymentMethod() throws {
        let expectation = XCTestExpectation(description: "createPaymentMethod() completed")
        
        var paymentMethod: OPPaymentMethodProtocol? = nil
        var error: Error? = nil
        
        initializer!.setup(for: .test) {
            OloPayAPI().createPaymentMethod(with: PaymentMethodParamsHelper.createValid()) { pm, e in
                paymentMethod = pm
                error = e
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: maxWaitSeconds)
        
        guard error == nil else {
            XCTFail("Error incorrectly thrown")
            return
        }

        guard let paymentMethod = paymentMethod as? OPPaymentMethod else {
            XCTFail("Payment method not created")
            return
        }
        
        XCTAssertEqual("4242", paymentMethod.last4)
        XCTAssertEqual(PaymentMethodParamsHelper.validExpYear, UInt(truncating: paymentMethod.expirationYear!))
        XCTAssertEqual(PaymentMethodParamsHelper.validExpMonth, UInt(truncating: paymentMethod.expirationMonth!))
        XCTAssertEqual(PaymentMethodParamsHelper.validPostalCode, paymentMethod.postalCode)
        XCTAssertFalse(paymentMethod.isApplePay)

    }
    
    func testCreatePaymentMethod_apiInitialized_paymentParamsInvalidNumber_throwsException() throws {
        let expectation = XCTestExpectation(description: "createPaymentMethod() completed")
        
        var paymentMethod: OPPaymentMethodProtocol? = nil
        var error: Error? = nil
        
        initializer!.setup(for: .test) {
            OloPayAPI().createPaymentMethod(with: PaymentMethodParamsHelper.createWithInvalidNumber()) { pm, e in
                paymentMethod = pm
                error = e
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: maxWaitSeconds)
        
        guard let cardError = error as? OPError else {
            XCTFail("Expected error of type OPError")
            return
        }
        
        XCTAssertEqual(OPErrorType.cardError, cardError.errorType)
        XCTAssertEqual(OPCardErrorType.invalidNumber, cardError.cardErrorType)
        XCTAssertNil(paymentMethod)
    }
    
    func testCreatePaymentMethod_apiInitialized_paymentParamsInvalidYear_throwsException() throws {
        let expectation = XCTestExpectation(description: "createPaymentMethod() completed")
        
        var paymentMethod: OPPaymentMethodProtocol? = nil
        var error: Error? = nil
        
        initializer!.setup(for: .test) {
            OloPayAPI().createPaymentMethod(with: PaymentMethodParamsHelper.createWithInvalidYear()) { pm, e in
                paymentMethod = pm
                error = e
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: maxWaitSeconds)
        
        guard let cardError = error as? OPError else {
            XCTFail("Expected error of type OPError")
            return
        }
        
        XCTAssertEqual(OPErrorType.cardError, cardError.errorType)
        XCTAssertEqual(OPCardErrorType.invalidExpYear, cardError.cardErrorType)
        XCTAssertNil(paymentMethod)
    }
    
    func testCreatePaymentMethod_apiInitialized_paymentParamsInvalidMonth_throwsException() throws {
        let expectation = XCTestExpectation(description: "createPaymentMethod() completed")
        
        var paymentMethod: OPPaymentMethodProtocol? = nil
        var error: Error? = nil
        
        initializer!.setup(for: .test) {
            OloPayAPI().createPaymentMethod(with: PaymentMethodParamsHelper.createWithInvalidMonth()) { pm, e in
                paymentMethod = pm
                error = e
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: maxWaitSeconds)
        
        guard let cardError = error as? OPError else {
            XCTFail("Expected error of type OPError")
            return
        }
        
        XCTAssertEqual(OPErrorType.cardError, cardError.errorType)
        XCTAssertEqual(OPCardErrorType.invalidExpMonth, cardError.cardErrorType)
        XCTAssertNil(paymentMethod)
    }
    
    func testCreatePaymentMethod_apiInitialized_paymentParamsInvalidCvv_throwsException() throws {
        let expectation = XCTestExpectation(description: "createPaymentMethod() completed")
        
        var paymentMethod: OPPaymentMethodProtocol? = nil
        var error: Error? = nil
        
        initializer!.setup(for: .test) {
            OloPayAPI().createPaymentMethod(with: PaymentMethodParamsHelper.createWithInvalidCvv()) { pm, e in
                paymentMethod = pm
                error = e
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: maxWaitSeconds)
        
        guard let cardError = error as? OPError else {
            XCTFail("Expected error of type OPError")
            return
        }
        
        XCTAssertEqual(OPErrorType.cardError, cardError.errorType)
        XCTAssertEqual(OPCardErrorType.invalidCvv, cardError.cardErrorType)
        XCTAssertNil(paymentMethod)
    }
    
    func testCreateCvvUpdateToken_apiInitialized_invalidPublishableKey_updatesKey() throws {
        let expectation = XCTestExpectation(description: "createCvvUpdateToken() completed")
        
        initializer!.setup(for: .test) {
            OloPayAPI.publishableKey = "foobar" //Reset the publishable key to an invalid one
            
            OloPayAPI().createCvvUpdateToken(with: CvvTokenParamsHelper.createValid()) { token, error in
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: maxWaitSeconds)
        
        XCTAssertNotEqual("foobar", OloPayAPI.publishableKey) //Make sure the publishable key it NOT what we set it to after initializing the API
    }
    
    func testCreateCvvUpdateToken_incorrectTokenParamsType_throwsInvalidRequestError() throws {
        let expectation = XCTestExpectation(description: "createCvvUpdateToken() completed")
        
        var token: OPCvvUpdateTokenProtocol? = nil
        var error: Error? = nil
        
        OloPayAPI().createCvvUpdateToken(with: CvvTokenParamsHelper.createIncorrectParamsType()) { t, e in
            token = t
            error = e
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: maxWaitSeconds)
        
        guard let error = error as? OPError else {
            XCTFail("Expected error of type OPError")
            return
        }
        
        XCTAssertEqual(OPErrorType.invalidRequestError, error.errorType)
        XCTAssertEqual("Params must be of type OPCvvTokenParams", error.localizedDescription)
        XCTAssertNil(token)
    }
    
    func testCreateCvvUpdateToken_apiInitialized_withValidCvv_returnsValidCvvUpdateToken() throws {
        let expectation = XCTestExpectation(description: "createCvvUpdateToken() completed")
        
        var token: OPCvvUpdateTokenProtocol? = nil
        var error: Error? = nil
        
        initializer!.setup(for: .test) {
            OloPayAPI().createCvvUpdateToken(with: CvvTokenParamsHelper.createValid()) { t, e in
                token = t
                error = e
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: maxWaitSeconds)
        
        guard let token = token else {
            XCTFail("Token not created")
            return
        }
        
        XCTAssertNotEqual("", token.id)
        XCTAssertEqual(OPEnvironment.test, token.environment)
        XCTAssertNil(error)
    }
    
    func testCreateCvvUpdateToken_apiInitialized_withEmptyCvv_throwsException() throws {
        let expectation = XCTestExpectation(description: "createCvvUpdateToken() completed")
        
        var token: OPCvvUpdateTokenProtocol? = nil
        var error: Error? = nil
        
        initializer!.setup(for: .test) {
            OloPayAPI().createCvvUpdateToken(with: CvvTokenParamsHelper.createInvalidWithEmptyCvv()) { t, e in
                token = t
                error = e
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: maxWaitSeconds)
        
        guard let cardError = error as? OPError else {
            XCTFail("Expected error of type OPError")
            return
        }
        
        XCTAssertEqual(OPErrorType.cardError, cardError.errorType)
        XCTAssertEqual(OPCardErrorType.invalidCvv, cardError.cardErrorType)
        XCTAssertEqual("Your card's security code is missing", cardError.localizedDescription)
        XCTAssertNil(token)
    }
    
    func testCreateCvvUpdateToken_apiInitialized_cvvWithTooFewDigits_throwsException() throws {
        let expectation = XCTestExpectation(description: "createCvvUpdateToken() completed")
        
        var token: OPCvvUpdateTokenProtocol? = nil
        var error: Error? = nil
        
        initializer!.setup(for: .test) {
            OloPayAPI().createCvvUpdateToken(with: CvvTokenParamsHelper.createInvalidWithTooFewDigits()) { t, e in
                token = t
                error = e
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: maxWaitSeconds)
        
        guard let cardError = error as? OPError else {
            XCTFail("Expected error of type OPError")
            return
        }
        
        XCTAssertEqual(OPErrorType.cardError, cardError.errorType)
        XCTAssertEqual(OPCardErrorType.invalidCvv, cardError.cardErrorType)
        XCTAssertNil(token)
    }
    
    func testCreateCvvUpdateToken_apiInitialized_cvvWithTooManyDigits_throwsException() throws {
        let expectation = XCTestExpectation(description: "createCvvUpdateToken() completed")
        
        var token: OPCvvUpdateTokenProtocol? = nil
        var error: Error? = nil
        
        initializer!.setup(for: .test) {
            OloPayAPI().createCvvUpdateToken(with: CvvTokenParamsHelper.createInvalidWithTooManyDigits()) { t, e in
                token = t
                error = e
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: maxWaitSeconds)
        
        guard let cardError = error as? OPError else {
            XCTFail("Expected error of type OPError")
            return
        }
        
        XCTAssertEqual(OPErrorType.cardError, cardError.errorType)
        XCTAssertEqual(OPCardErrorType.invalidCvv, cardError.cardErrorType)
        XCTAssertNil(token)
    }
    
    func testCreateCvvUpdateToken_apiInitialized_cvvWithCharacters_throwsException() throws {
        let expectation = XCTestExpectation(description: "createCvvUpdateToken() completed")
        
        var token: OPCvvUpdateTokenProtocol? = nil
        var error: Error? = nil
        
        initializer!.setup(for: .test) {
            OloPayAPI().createCvvUpdateToken(with: CvvTokenParamsHelper.createInvalidWithCharacters()) { t, e in
                token = t
                error = e
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: maxWaitSeconds)
        
        guard let cardError = error as? OPError else {
            XCTFail("Expected error of type OPError")
            return
        }
        
        XCTAssertEqual(OPErrorType.cardError, cardError.errorType)
        XCTAssertEqual(OPCardErrorType.invalidCvv, cardError.cardErrorType)
        XCTAssertNil(token)
    }
    
    func testUpdatePublishableKey_storesKey() throws {
        let expectation = XCTestExpectation(description: "updatePublishableKey() completed")
        
        initializer!.setup(for: .test) {
            OloPayAPI.publishableKey = ""
            
            OloPayAPI.updatePublishableKey {
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: maxWaitSeconds)
        
        XCTAssertFalse(OloPayAPI.publishableKey.isEmpty)
    }
    
    func testUpdatePublishableKeyForUrl_urlDoesNotReturnPublishableKey_publishableKeyNotUpdated() {
        let expectation = XCTestExpectation(description: "updatePublishableKey() completed")
        
        initializer!.setup(for: .test) {
            OloPayAPI.publishableKey = ""
            
            let url = URL(string: "https://static.olocdn.net")
            
            let task = OloPayAPI.updatePublishableKey(for: url!) {
                expectation.fulfill()
            }
            
            task.resume()
        }
        
        wait(for: [expectation], timeout: maxWaitSeconds)

        XCTAssertTrue(OloPayAPI.publishableKey.isEmpty)
    }
    
    func testUpdatePublishableKeyForUrl_urlDoesNotReturnData_publishableKeyNotUpdated() {
        let expectation = XCTestExpectation(description: "updatePublishableKey() completed")
        
        initializer!.setup(for: .test) {
            OloPayAPI.publishableKey = ""
            
            let invalidUrl = URL(string: "https://foo.bar")
            
            let task = OloPayAPI.updatePublishableKey(for: invalidUrl!) {
                expectation.fulfill()
            }
            
            task.resume()
        }
        
        wait(for: [expectation], timeout: maxWaitSeconds)
        XCTAssertTrue(OloPayAPI.publishableKey.isEmpty)
    }
    
    private class CvvTokenParamsHelper {
        static let validCvv = "234"
        static let invalidCvvEmpty = ""
        static let invalidCvvWithTooFewDigits = "23"
        static let invalidCvvWithTooManyDigits = "1234556"
        static let invalidCvvWithCharacters = "1a2"
        
        static func createValid() -> OPCvvTokenParamsProtocol {
            return OPCvvTokenParams(validCvv)
        }
        
        static func createInvalidWithEmptyCvv() -> OPCvvTokenParamsProtocol {
            return OPCvvTokenParams(invalidCvvEmpty)
        }
        
        static func createInvalidWithTooFewDigits() -> OPCvvTokenParamsProtocol {
            return OPCvvTokenParams(invalidCvvWithTooFewDigits)
        }
        
        static func createInvalidWithTooManyDigits() -> OPCvvTokenParamsProtocol {
            return OPCvvTokenParams(invalidCvvWithTooManyDigits)
        }
        
        static func createInvalidWithCharacters() -> OPCvvTokenParamsProtocol {
            return OPCvvTokenParams(invalidCvvWithCharacters)
        }
        
        static func createIncorrectParamsType() -> OPCvvTokenParamsProtocol {
            return InvalidCvvTokenParams()
        }
    }
    
    private class PaymentMethodParamsHelper {
        static let validCardNumber = "4242424242424242"
        static let diningClubCardNumber = "3056930009020004"
        static let invalidCardNumber = "1234567890123456"
        static let validExpYear: UInt = 2025
        static let invalidExpYear: UInt = 2020
        static let validExpMonth: UInt = 12
        static let invalidExpMonth: UInt = 24
        static let validCvv = "234"
        static let invalidCvv = "12"
        static let validPostalCode = "10004"
        
        static func createValid() -> OPPaymentMethodParamsProtocol {
            return OPPaymentMethodParams(createStripePaymentMethod(), fromSource: OPPaymentMethodSource.singleLineInput)
        }
        
        static func createValidWithCrossBrandCard() -> OPPaymentMethodParamsProtocol {
            return OPPaymentMethodParams(
                createStripePaymentMethod(cardNumber: diningClubCardNumber),
                fromSource: OPPaymentMethodSource.singleLineInput
            )
        }
        
        static func createWithInvalidNumber() -> OPPaymentMethodParamsProtocol {
            let paymentMethod = createStripePaymentMethod()
            paymentMethod.card?.number = invalidCardNumber
            return OPPaymentMethodParams(paymentMethod, fromSource: OPPaymentMethodSource.singleLineInput)
        }
        
        static func createWithInvalidYear() -> OPPaymentMethodParamsProtocol {
            let paymentMethod = createStripePaymentMethod()
            paymentMethod.card?.expYear = NSNumber(value: invalidExpYear)
            return OPPaymentMethodParams(paymentMethod, fromSource: OPPaymentMethodSource.singleLineInput)
        }
        
        static func createWithInvalidMonth() -> OPPaymentMethodParamsProtocol {
            let paymentMethod = createStripePaymentMethod()
            paymentMethod.card?.expMonth = NSNumber(value: invalidExpMonth)
            return OPPaymentMethodParams(paymentMethod, fromSource: OPPaymentMethodSource.singleLineInput)
        }
        
        static func createWithInvalidCvv() -> OPPaymentMethodParamsProtocol {
            let paymentMethod = createStripePaymentMethod()
            paymentMethod.card?.cvc = invalidCvv
            return OPPaymentMethodParams(paymentMethod, fromSource: OPPaymentMethodSource.singleLineInput)
        }
        
        static func createIncorrectParamsType() -> OPPaymentMethodParamsProtocol {
            return InvalidPaymentMethodParams()
        }
        
        static func createStripePaymentMethod(cardNumber: String = validCardNumber) -> STPPaymentMethodParams {
            let cardParams = STPCardParams()
            cardParams.number = cardNumber
            cardParams.expYear = validExpYear
            cardParams.expMonth = validExpMonth
            cardParams.cvc = validCvv
            
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
    
    private class InvalidPaymentMethodParams : NSObject, OPPaymentMethodParamsProtocol {}
    private class InvalidCvvTokenParams : NSObject, OPCvvTokenParamsProtocol {}
}
