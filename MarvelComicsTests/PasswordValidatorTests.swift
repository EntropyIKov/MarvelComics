//
//  PasswordValidatorTests.swift
//  MarvelComicsTests
//
//  Created by Kovalenko Ilia on 15/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import XCTest
@testable import MarvelComics

class PasswordValidatorTests: XCTestCase {
    
    func testPasswordValidator() {
        let password = Constants.correctPassword
        XCTAssertTrue(PasswordValidator.validate(string: password))
    }

    func testPasswordTooShort() {
        let password = Constants.tooShortPassword
        XCTAssertFalse(PasswordValidator.validate(string: password))
    }
    
    func testPasswordIsNil() {
        let password = Constants.passwordIsNil
        XCTAssertFalse(PasswordValidator.validate(string: password))
    }
}

private extension PasswordValidatorTests {
    enum Constants {
        static let correctPassword = "asdas!123"
        static let tooShortPassword = "hard"
        static let passwordIsNil: String? = nil
    }
}
