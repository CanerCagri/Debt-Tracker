//
//  LoginViewController.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 9.02.2023.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    let detailLabel = DTTitleLabel(textAlignment: .left, fontSize: 24, text: "Login Account")
    let emailTextField = DTTextField(placeholder: "Your Email", placeHolderSize: 15, cornerRadius: 14)
    let passwordTextField = DTTextField(placeholder: "Password", placeHolderSize: 15, cornerRadius: 14)
    let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
    let showPasswordButton = UIButton(type: .system)
    let loginButton = DTButton(title: "LOGIN", color: .systemPink, systemImageName: "checkmark.circle")
    var forgetPasswordLabel = DTTitleLabel(textAlignment: .center, fontSize: 18, textColor: .systemGray2, text: "Forgot Password?")
    let dontHaveAccLabel = DTTitleLabel(textAlignment: .center, fontSize: 16, textColor: .label, text: "Don't have an account?")
    let registerLabel = DTTitleLabel(textAlignment: .center, fontSize: 18, textColor: .systemGray2, text: "REGISTER")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        applyConstraints()
    }
    
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        passwordTextField.isSecureTextEntry = true
    
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
        passwordTextField.leftView = leftPaddingView
        passwordTextField.leftViewMode = .always
        
        showPasswordButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        showPasswordButton.frame = CGRect(x: -5, y: 0, width: 30, height: 30)
        showPasswordButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)

        passwordTextField.rightView = containerView
        passwordTextField.rightViewMode = .always
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        forgetPasswordLabel.isUserInteractionEnabled = true
        registerLabel.isUserInteractionEnabled = true
        let forgetPasswordTapGesture = UITapGestureRecognizer(target: self, action: #selector(showForgetPasswordPopup))
        forgetPasswordLabel.addGestureRecognizer(forgetPasswordTapGesture)
        
        let registerTapGesture = UITapGestureRecognizer(target: self, action: #selector(registerPagePresent))
        registerLabel.addGestureRecognizer(registerTapGesture)
        
    }
    
    @objc func loginButtonTapped() {
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    let tabBarVC = MainTabBarViewController()
                    tabBarVC.modalPresentationStyle = .fullScreen
                    self?.present(tabBarVC, animated: true)
                }
                
            }
        }
    }
    
    @objc func showForgetPasswordPopup() {
           print("test")
       }
    
    @objc func registerPagePresent() {
        let registerVC = RegisterViewController()
        navigationController?.pushViewController(registerVC, animated: true)
    }
    
    @objc func togglePasswordVisibility() {
         passwordTextField.isSecureTextEntry.toggle()

         if passwordTextField.isSecureTextEntry {
             showPasswordButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
         } else {
             showPasswordButton.setImage(UIImage(systemName: "eye"), for: .normal)
         }
     }
    
    private func applyConstraints() {
        view.addSubviews(detailLabel, emailTextField, passwordTextField, loginButton, forgetPasswordLabel, dontHaveAccLabel, registerLabel)
        containerView.addSubview(showPasswordButton)
        
        detailLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        detailLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
        
        emailTextField.topAnchor.constraint(equalTo: detailLabel.bottomAnchor, constant: 50).isActive = true
        emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 10).isActive = true
        passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20).isActive = true
        loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        forgetPasswordLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        forgetPasswordLabel.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 5).isActive = true
        
        registerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        registerLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
        
        dontHaveAccLabel.bottomAnchor.constraint(equalTo: registerLabel.topAnchor, constant: -5).isActive = true
        dontHaveAccLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
    }
}