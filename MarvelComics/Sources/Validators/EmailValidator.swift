//
//  EmailValidator.swift
//  MarvelComics
//
//  Created by Kovalenko Ilia on 14/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import Foundation

class EmailValidator: ValidatorProtocol {
    static func validate(string: String?) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let isEmailValid = emailTest.evaluate(with: string)
        return isEmailValid
    }
}
