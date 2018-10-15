//
//  EmailValidatorTests.swift
//  MarvelComicsTests
//
//  Created by Kovalenko Ilia on 15/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import XCTest
@testable import MarvelComics

class EmailValidatorTests: XCTestCase {
    
    func testCorrectEmail() {
        let email = Constants.correctEmail
        XCTAssertTrue(EmailValidator.validate(string: email))
    }
    
    func testEmailHaveNotDomain() {
        let email = Constants.haveNotDomain
        XCTAssertFalse(EmailValidator.validate(string: email))
    }
    
    func testEmailHaveIncorrexctSequence() {
        let email = Constants.incorrectSequence
        XCTAssertFalse(EmailValidator.validate(string: email))
    }
    
    func testEmailIsNil() {
        let email = Constants.stringIsNil
        XCTAssertFalse(EmailValidator.validate(string: email))
    }
    
    func testEmailHaveNotName() {
        let email = Constants.haveNotEmailName
        XCTAssertFalse(EmailValidator.validate(string: email))
    }
    
}

private extension EmailValidatorTests {
    enum Constants {
        static let correctEmail = "email@mail.com"
        static let haveNotDomain = "dads@.sdas"
        static let incorrectSequence = "adsda@sdad.dadsa@"
        static let stringIsNil: String? = nil
        static let haveNotEmailName = "@s.ss"
    }
}
