//
//  AuthorisationViewController.swift
//  MarvelComics
//
//  Created by Kovalenko Ilia on 04/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import UIKit

class AuthorisationViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    //MARK: - Variables
    private var isEmailValid = false
    private var isPasswordValid = false
    
    //MARK: - Actions
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews() {
        signInButton.isEnabled = false
        signInButton.addTarget(self, action: #selector(buttonAction(sender: )), for: .touchUpInside)
        
        emailTextField.addTarget(self, action: #selector(checkEmail(sender: )), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(checkPassword(sender: )), for: .editingChanged)
    }
    
    @objc private func buttonAction(sender: UIButton) {
        performSegue(withIdentifier: "AuthSegue", sender: nil)
    }
    
    @objc private func checkEmail(sender: UITextField) {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let email = sender.text
        
        // idk how it works(
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        isEmailValid = emailTest.evaluate(with: email)
        changeButtonState()
    }
    
    @objc private func checkPassword(sender: UITextField) {
        if let password = sender.text, password.count >= 6{
            isPasswordValid = true
        } else {
            isPasswordValid = false
        }
        changeButtonState()
    }
    
    private func changeButtonState() {
        if isEmailValid && isPasswordValid {
            signInButton.isEnabled = true
        } else {
            signInButton.isEnabled = false
        }
    }
    
}
