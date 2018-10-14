//
//  ValidatorTests.swift
//  MarvelComicsTests
//
//  Created by Kovalenko Ilia on 14/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import XCTest
@testable import MarvelComics

class ValidatorTests: XCTestCase {
    
    func testEmailValidator() {
        let rightEmailsArray = ["s@s.ss", "email@mail.com", "super@gmail.com"]
        let wrongEmailsArray = ["@s.ss", "dads@.sdas", "adsda@sdad.dadsa@", nil]
        for email in rightEmailsArray {
            XCTAssertTrue(EmailValidator.validate(string: email))
        }
        for email in wrongEmailsArray {
            XCTAssertFalse(EmailValidator.validate(string: email))
        }
    }
    
    func testPasswordValidator() {
        let rightPasswordsArray = ["asdasd@das", ",asdas!123", "msasd@12dws"]
        let wrongPasswordsArray = ["hard", "stron", "sa1", nil]
        for password in rightPasswordsArray {
            XCTAssertTrue(PasswordValidator.validate(string: password))
        }
        for password in wrongPasswordsArray {
            XCTAssertFalse(PasswordValidator.validate(string: password))
        }
    }

}
