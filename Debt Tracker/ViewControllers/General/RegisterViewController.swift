//
//  RegisterViewController.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 9.02.2023.
//

import UIKit
import Firebase
import AuthenticationServices
import FacebookLogin
import FacebookCore

class RegisterViewController: UIViewController {
    
    let detailLabel = DTTitleLabel(textAlignment: .left, fontSize: 24, text: "Register Account")
    let emailTextField = DTTextField(placeholder: "Your Email", placeHolderSize: 15, cornerRadius: 14)
    let passwordTextField = DTTextField(placeholder: "Password", placeHolderSize: 15, cornerRadius: 14)
    let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
    let showPasswordButton = UIButton(type: .system)
    let registerButton = DTButton(title: "REGISTER", color: .systemPink, systemImageName: "checkmark.circle", size: 20)
    private let appleSignInButton = ASAuthorizationAppleIDButton(type: .continue, style: .black)
    private let facebookSignInButton = DTFacebookSigninButton(iconCentered: true)
    
    fileprivate var currentNonce: String?
    var isLoginTapped = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        applyConstraints()
    }
    
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
        passwordTextField.leftView = leftPaddingView
        passwordTextField.leftViewMode = .always
        passwordTextField.rightView = containerView
        passwordTextField.rightViewMode = .always
        passwordTextField.isSecureTextEntry = true
        
        showPasswordButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        showPasswordButton.frame = CGRect(x: -5, y: 0, width: 30, height: 30)
        showPasswordButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        appleSignInButton.addTarget(self, action: #selector(didTapSignInWithApple), for: .touchUpInside)
        facebookSignInButton.addTarget(self, action: #selector(signInWithFacebookPressed), for: .touchUpInside)
    }
    
    @objc func didTapSignInWithApple() {
        let nonce = UIHelper.randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = UIHelper.sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @objc func signInWithFacebookPressed() {
        LoginManager().logIn(permissions: ["public_profile", "email"], from: self) { result, error in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            
            guard let resultTokenString = result?.token?.tokenString else { return }
            let credential = FacebookAuthProvider.credential(withAccessToken: resultTokenString)
            
            AuthManager.shared.signInUserWith(with: credential) { [weak self] result in
                switch result {
                case .success(_):
                    self?.openMainTabBarVc()
                case .failure(let failure):
                    self?.presentAlert(title: "Warning", message: failure.localizedDescription, buttonTitle: "OK")
                }
            }
        }
    }
    
    @objc func registerButtonTapped() {
        if let email = emailTextField.text, let password = passwordTextField.text {
            
            AuthManager.shared.createUser(email: email, password: password) { [weak self] result in
                switch result {
                case .success(_):
                    self?.navigationController?.popToRootViewController(animated: true)
                case .failure(let failure):
                    self?.presentAlert(title: "Warning", message: failure.localizedDescription, buttonTitle: "OK")
                }
            }
        }
    }
    
    @objc func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle()
        
        if passwordTextField.isSecureTextEntry {
            showPasswordButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        } else {
            showPasswordButton.setImage(UIImage(systemName: "eye"), for: .normal)
        }
    }

    func openMainTabBarVc() {
        if !isLoginTapped {
            let tabBarVC = MainTabBarViewController()
            tabBarVC.navigationItem.hidesBackButton = true
            navigationController?.pushViewController(tabBarVC, animated: true)
            isLoginTapped = true
        }
    }
    
    private func applyConstraints() {
        view.addSubviews(detailLabel, emailTextField, passwordTextField, registerButton, appleSignInButton, facebookSignInButton)
        containerView.addSubview(showPasswordButton)
        appleSignInButton.translatesAutoresizingMaskIntoConstraints = false
        
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
        
        registerButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20).isActive = true
        registerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        registerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        appleSignInButton.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 80).isActive = true
        appleSignInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        appleSignInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        appleSignInButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        facebookSignInButton.topAnchor.constraint(equalTo: appleSignInButton.bottomAnchor, constant: 20).isActive = true
        facebookSignInButton.leadingAnchor.constraint(equalTo: appleSignInButton.leadingAnchor).isActive = true
        facebookSignInButton.trailingAnchor.constraint(equalTo: appleSignInButton.trailingAnchor).isActive = true
        facebookSignInButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
}

extension RegisterViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        presentAlert(title: "Warning", message: error.localizedDescription, buttonTitle: "OK")
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            
            AuthManager.shared.signInUserWith(with: credential) { [weak self] result in
                switch result {
                case .success(_):
                    self?.openMainTabBarVc()
                case .failure(let failure):
                    self?.presentAlert(title: "Warning", message: failure.localizedDescription, buttonTitle: "OK")
                }
            }
        }
    }
}

extension RegisterViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}
