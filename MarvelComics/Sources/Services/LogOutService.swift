//
//  LogOutService.swift
//  MarvelComics
//
//  Created by Kovalenko Ilia on 08/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import Foundation
import UIKit

class LogOutService {
    @objc static func logOut() {
        let authorizationViewController = AuthorizationViewController.storyboardInstance
        UIApplication.shared.keyWindow?.rootViewController = authorizationViewController
    }
}
