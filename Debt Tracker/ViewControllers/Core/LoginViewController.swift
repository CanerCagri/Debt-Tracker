//
//  LoginViewController.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 9.02.2023.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn
import FacebookLogin


class LoginViewController: UIViewController, LoginButtonDelegate {

    let detailLabel = DTTitleLabel(textAlignment: .left, fontSize: 24, text: "Login Account")
    let emailTextField = DTTextField(placeholder: "Your Email", placeHolderSize: 15, cornerRadius: 14)
    let passwordTextField = DTTextField(placeholder: "Password", placeHolderSize: 15, cornerRadius: 14)
    let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
    let showPasswordButton = UIButton(type: .system)
    let loginButton = DTButton(title: "LOGIN", color: .systemPink, systemImageName: "checkmark.circle")
    var forgetPasswordLabel = DTTitleLabel(textAlignment: .center, fontSize: 18, textColor: .systemGray2, text: "Forgot Password?")
    let dontHaveAccLabel = DTTitleLabel(textAlignment: .center, fontSize: 16, textColor: .label, text: "Don't have an account?")
    let registerLabel = DTTitleLabel(textAlignment: .center, fontSize: 18, textColor: .systemGray2, text: "REGISTER")
    let googleSignInButton = GIDSignInButton()
    let facebookLoginButton = FBLoginButton()
    
    var isLoginTapped = false
    var isRightBarButtonTapped = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        applyConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emailTextField.text = ""
        passwordTextField.text = ""
        isLoginTapped = false
        
        emailTextField.text = "1@gmail.com"
        passwordTextField.text = "123456"
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(didTapRightBarButton), name: .didTapRightBarButton, object: nil)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("resetCloseTapped"), object: nil, queue: nil) { [weak self] (notification) in
            self?.isRightBarButtonTapped = false
        }
        
        googleSignInButton.addTarget(self, action: #selector(signInWithGooglePressed), for: .touchUpInside)
        
        if let token = AccessToken.current,
                !token.isExpired {
                // User is logged in, do work such as go to next view controller.
            }
        
    }
    
    
    @objc func signInWithGooglePressed() {
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] signInResult, err in
            
            if let error = err {
                print(error.localizedDescription)
                return
            }
            
            guard let authentication = signInResult?.user, let idToken = authentication.idToken?.tokenString else { return }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken.tokenString)
            
            AuthManager.shared.signInUserWithGoogle(credential: credential) { [weak self] result in
                switch result {
                case .success(_):
                    self?.isLoginTapped = true
                    let tabBarVC = MainTabBarViewController()
                    tabBarVC.navigationItem.hidesBackButton = true
                    self?.navigationController?.pushViewController(tabBarVC, animated: true)
                case .failure(let failure):
                    self?.presentAlert(title: "Warning", message: failure.localizedDescription, buttonTitle: "OK")
                }
            }
        }
    }
    
    @objc func didTapRightBarButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @objc func loginButtonTapped() {
        if let email = emailTextField.text, let password = passwordTextField.text {
            
            if isLoginTapped != true {
                
                AuthManager.shared.signInUser(email: email, password: password) { [weak self] result in
                    switch result {
                    case .success(_):
                        self?.isLoginTapped = true
                        let tabBarVC = MainTabBarViewController()
                        tabBarVC.navigationItem.hidesBackButton = true
                        self?.navigationController?.pushViewController(tabBarVC, animated: true)
                    case .failure(let failure):
                        self?.presentAlert(title: "Warning", message: failure.localizedDescription, buttonTitle: "OK")
                    }
                }
            }
        }
    }
    
    @objc func showForgetPasswordPopup() {
        if !isRightBarButtonTapped {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2 ) { [weak self] in
                let popupVc = ForgotPasswordVc()
                
                self?.addChild(popupVc)
                self?.view.addSubview(popupVc.view)
                popupVc.didMove(toParent: self)
            }
            isRightBarButtonTapped = true
        }
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
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {

    }

    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
          }

        let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)

        AuthManager.shared.signInUserWithGoogle(credential: credential) { [weak self] result in
            switch result {
            case .success(_):
                self?.isLoginTapped = true
                let tabBarVC = MainTabBarViewController()
                tabBarVC.navigationItem.hidesBackButton = true
                self?.navigationController?.pushViewController(tabBarVC, animated: true)
            case .failure(let failure):
                self?.presentAlert(title: "Warning", message: failure.localizedDescription, buttonTitle: "OK")
            }
        }
    }
    
    private func applyConstraints() {
        view.addSubviews(detailLabel, emailTextField, passwordTextField, loginButton, forgetPasswordLabel, googleSignInButton, facebookLoginButton, dontHaveAccLabel, registerLabel)
        containerView.addSubview(showPasswordButton)
        googleSignInButton.translatesAutoresizingMaskIntoConstraints = false
        facebookLoginButton.translatesAutoresizingMaskIntoConstraints = false
        googleSignInButton.style = .wide
        googleSignInButton.colorScheme = .light
        facebookLoginButton.delegate = self
        facebookLoginButton.permissions = ["public_profile", "email"]
        
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
        
        googleSignInButton.topAnchor.constraint(equalTo: forgetPasswordLabel.bottomAnchor, constant: 20).isActive = true
        googleSignInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        googleSignInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        googleSignInButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        facebookLoginButton.topAnchor.constraint(equalTo: googleSignInButton.bottomAnchor, constant: 10).isActive = true
        facebookLoginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        facebookLoginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        
        registerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        registerLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
        
        dontHaveAccLabel.bottomAnchor.constraint(equalTo: registerLabel.topAnchor, constant: -5).isActive = true
        dontHaveAccLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
    }
}
