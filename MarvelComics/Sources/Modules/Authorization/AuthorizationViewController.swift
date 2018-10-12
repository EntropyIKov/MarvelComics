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
    static var storyboardInstance: AuthorizationViewController? = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateInitialViewController() as? AuthorizationViewController
    }()
    private var isEmailValid = false
    private var isPasswordValid = false
    
    //MARK: - Actions
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews() {
        signInButton.isEnabled = false
        
        emailTextField.addTarget(self, action: #selector(checkEmail(sender: )), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(checkPassword(sender: )), for: .editingChanged)
    }
    
    @IBAction func signInButtonDidTaped(_ sender: UIButton) {
        if let mainScreenTabBarViewController = MainScreenTabBarController.storyboardInstance {
            UIApplication.shared.keyWindow?.rootViewController = mainScreenTabBarViewController
        }
    }
}

private extension AuthorizationViewController {
    
    @objc private func checkEmail(sender: UITextField) {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let email = sender.text
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        isEmailValid = emailTest.evaluate(with: email)
        changeSignInButtonState()
    }
    
    @objc private func checkPassword(sender: UITextField) {
        if let password = sender.text, password.count >= 6{
            isPasswordValid = true
        } else {
            isPasswordValid = false
        }
        changeSignInButtonState()
    }
    
    private func changeSignInButtonState() {
        signInButton.isEnabled = isEmailValid && isPasswordValid
    }
}
