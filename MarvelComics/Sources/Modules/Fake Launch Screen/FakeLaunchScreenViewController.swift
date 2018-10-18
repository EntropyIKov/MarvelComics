//
//  FakeLaunchScreenViewController.swift
//  MarvelComics
//
//  Created by Kovalenko Ilia on 18/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import UIKit

class FakeLaunchScreenViewController: UIViewController {

    
    @IBOutlet weak var logoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        
        if let _ = KeyChainService.shared["email"] {
            transitToMainScreen()
        } else {
            transitToAuthScreen()
        }
        
//        let defaults = UserDefaults.standard
//        if let _ = defaults.string(forKey: DefaultsKeys.keyEmail) {
//            transitToMainScreen()
//        } else {
//            transitToAuthScreen()
//        }
    }
    
    private func transitToMainScreen() {
        let mainScreenTabBarViewController = MainScreenTabBarController.storyboardInstance
        UIApplication.shared.keyWindow?.rootViewController = mainScreenTabBarViewController
        UIApplication.shared.keyWindow?.makeKeyAndVisible()
    }
    
    private func transitToAuthScreen() {
        let authorizationViewController = AuthorizationViewController.storyboardInstance
        UIApplication.shared.keyWindow?.rootViewController = authorizationViewController
        UIApplication.shared.keyWindow?.makeKeyAndVisible()
    }

}
