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
    static var storyboardInstance: AuthorizationViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateInitialViewController() as! AuthorizationViewController
    }
    
    //MARK: - Actions
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews() {
        signInButton.titleLabel?.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        signInButton.backgroundColor = #colorLiteral(red: 0.6247377992, green: 0.002765463199, blue: 0.0718748793, alpha: 1)
        signInButton.isEnabled = false
    }
    
    @IBAction func signInButtonDidTaped(_ sender: UIButton) {        
        KeyChainService.shared["email"] = emailTextField.text        
        transitToMainScreen()
        
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
        if signInButton.isEnabled {
            signInButton.titleLabel?.textColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
            signInButton.backgroundColor = #colorLiteral(red: 0.9227598906, green: 0.1393100321, blue: 0.1546708345, alpha: 1)
        } else {
            signInButton.titleLabel?.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            signInButton.backgroundColor = #colorLiteral(red: 0.6247377992, green: 0.002765463199, blue: 0.0718748793, alpha: 1)
        }
    }
    
    private func transitToMainScreen() {
        let mainScreenTabBarViewController = MainScreenTabBarController.storyboardInstance
        UIApplication.shared.keyWindow?.rootViewController = mainScreenTabBarViewController
        UIApplication.shared.keyWindow?.makeKeyAndVisible()
    }
}
