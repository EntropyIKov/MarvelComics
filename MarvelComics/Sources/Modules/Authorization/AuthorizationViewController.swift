//
//  AuthorisationViewController.swift
//  MarvelComics
//
//  Created by Kovalenko Ilia on 04/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import UIKit

class AuthorizationViewController: UIViewController {
    
    
    //MARK: - Outlets
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var signInButton: UIButton!
    
    //MARK: - Variables
    private var isEmailValid = false
    private var isPasswordValid = false
    static var storyboardInstance: AuthorizationViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateInitialViewController() as! AuthorizationViewController
    }()
    
    //MARK: - Actions
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews() {
        signInButton.isEnabled = false
    }
    
    @IBAction func signInButtonDidTaped(_ sender: UIButton) {
        let mainScreenTabBarViewController = MainScreenTabBarController.storyboardInstance
        UIApplication.shared.keyWindow?.rootViewController = mainScreenTabBarViewController
        UIApplication.shared.keyWindow?.makeKeyAndVisible()
        
        
//        if let mainScreenTabBarViewController = MainScreenTabBarController.storyboardInstance {
//
//            self.present(mainScreenTabBarViewController, animated: true) {
//                UIApplication.shared.keyWindow?.rootViewController = mainScreenTabBarViewController
//            }
//        }
    }
    
    @IBAction func emailTextFieldEditingChangedHandler(_ sender: UITextField) {
        let email = sender.text
        isEmailValid = EmailValidator.validate(string: email)
        changeSignInButtonState()
    }
    
    @IBAction func passwordTextFieldEditingChangedHandler(_ sender: UITextField) {
        isPasswordValid = PasswordValidator.validate(string: sender.text)
        changeSignInButtonState()
    }
}

private extension AuthorizationViewController {
    
    private func changeSignInButtonState() {
        signInButton.isEnabled = isEmailValid && isPasswordValid
    }
}
