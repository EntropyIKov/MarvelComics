//
//  PasswordValidator.swift
//  MarvelComics
//
//  Created by Kovalenko Ilia on 14/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import Foundation

class PasswordValidator: ValidatorProtocol {
    static func validate(string: String?) -> Bool {
        if let password = string, password.count >= 6{
            return true
        } else {
            return false
        }
    }
}
