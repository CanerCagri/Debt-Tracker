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
    
    let contentSizeHeight: CGFloat = DeviceTypes.isiPhoneSE || DeviceTypes.isiPhone8PlusZoomed || DeviceTypes.isiPhone8Standard || DeviceTypes.isiPhone8Zoomed || DeviceTypes.isiPhone8PlusStandard ? 150 : 0
    
    lazy var contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height + contentSizeHeight)
    
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView(frame: .zero)
        view.contentSize = contentSize
        view.frame = self.view.bounds
        view.autoresizingMask = .flexibleHeight
        view.bounces = true
        view.showsHorizontalScrollIndicator = true
        return view
    }()
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.frame.size = contentSize
        return view
    }()
    
    let detailLabel = DTTitleLabel(textAlignment: .left, fontSize: 24, text: "Register Account")
    let emailTextField = DTTextField(placeholder: "Your Email", placeHolderSize: 15)
    let passwordTextField = DTTextField(placeholder: "Password", placeHolderSize: 15)
    let rePasswordTextField = DTTextField(placeholder: "Re-Password", placeHolderSize: 15)
    let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
    let reContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
    let showPasswordButton = UIButton(type: .system)
    let reShowPasswordButton = UIButton(type: .system)
    let registerButton = DTButton(title: "REGISTER", color: .systemPink, systemImageName: SFSymbols.checkMarkSymbol, size: 20)
    private let facebookSignInButton = DTFacebookSigninButton(iconCentered: true)
    private let appleSignInButton: ASAuthorizationAppleIDButton = ASAuthorizationAppleIDButton(
        authorizationButtonType: .continue,
        authorizationButtonStyle: UITraitCollection.current.userInterfaceStyle == .dark ? .white : .black
    )
    
    fileprivate var currentNonce: String?
    let viewModel = RegisterViewModel()
    var isKeyboardAppear = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        applyConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emailTextField.text = ""
        contentView.endEditing(true)
    }
    
    private func configureViewController() {
        view.setBackgroundColor()
        contentView.setBackgroundColor()
        hideKeyboardWheTappedAround()
        viewModel.delegate = self
        emailTextField.delegate = self
        
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
        passwordTextField.leftView = leftPaddingView
        passwordTextField.leftViewMode = .always
        passwordTextField.rightView = containerView
        passwordTextField.rightViewMode = .always
        passwordTextField.isSecureTextEntry = true
        passwordTextField.delegate = self
        
        let reLeftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
        rePasswordTextField.leftView = reLeftPaddingView
        rePasswordTextField.leftViewMode = .always
        rePasswordTextField.rightView = reContainerView
        rePasswordTextField.rightViewMode = .always
        rePasswordTextField.isSecureTextEntry = true
        rePasswordTextField.delegate = self
        
        showPasswordButton.setImage(UIImage(systemName: SFSymbols.hidePasswordSymbol), for: .normal)
        showPasswordButton.frame = CGRect(x: -5, y: 0, width: 30, height: 30)
        showPasswordButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        
        reShowPasswordButton.setImage(UIImage(systemName: SFSymbols.hidePasswordSymbol), for: .normal)
        reShowPasswordButton.frame = CGRect(x: -5, y: 0, width: 30, height: 30)
        reShowPasswordButton.addTarget(self, action: #selector(reTogglePasswordVisibility), for: .touchUpInside)
        
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        appleSignInButton.addTarget(self, action: #selector(didTapSignInWithApple), for: .touchUpInside)
        facebookSignInButton.addTarget(self, action: #selector(signInWithFacebookPressed), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        contentView.addGestureRecognizer(tap)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if !isKeyboardAppear {
            scrollView.isScrollEnabled = true
            isKeyboardAppear = true
        }
    }
    
    @objc func dismissKeyboard() {
        if isKeyboardAppear {
            scrollView.isScrollEnabled = false
            let topRect = CGRect(x: 0, y: 0, width: 1, height: 1)
            scrollView.scrollRectToVisible(topRect, animated: true)
            contentView.endEditing(true)
            isKeyboardAppear = false
        }
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
        LoginManager().logIn(permissions: [K.publicProfile, K.email], from: self) { [weak self] result, error in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            
            guard let resultTokenString = result?.token?.tokenString else { return }
            let credential = FacebookAuthProvider.credential(withAccessToken: resultTokenString)
            
            self?.showLoading()
            self?.viewModel.signInUserWith(with: credential)
        }
    }
    
    @objc func registerButtonTapped() {
        if let email = emailTextField.text, let password = passwordTextField.text, let rePassword = rePasswordTextField.text {
            if password == rePassword {
                showLoading()
                viewModel.createUser(email: email, password: password)
                
            } else {
                presentAlert(title: "Warning", message: "Passwords Do Not Match", buttonTitle: "OK")
            }
        }
    }
    
    @objc func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle()
        
        if passwordTextField.isSecureTextEntry {
            showPasswordButton.setImage(UIImage(systemName: SFSymbols.hidePasswordSymbol), for: .normal)
        } else {
            showPasswordButton.setImage(UIImage(systemName: SFSymbols.showPasswordSymbol), for: .normal)
        }
    }
    
    @objc func reTogglePasswordVisibility() {
        rePasswordTextField.isSecureTextEntry.toggle()
        
        if rePasswordTextField.isSecureTextEntry {
            reShowPasswordButton.setImage(UIImage(systemName: SFSymbols.hidePasswordSymbol), for: .normal)
        } else {
            reShowPasswordButton.setImage(UIImage(systemName: SFSymbols.showPasswordSymbol), for: .normal)
        }
    }
    
    func openMainTabBarVc() {
        let tabBarVC = MainTabBarViewController()
        tabBarVC.navigationItem.hidesBackButton = true
        navigationController?.pushViewController(tabBarVC, animated: true)
    }
    
    private func applyConstraints() {
        view.addSubview(scrollView)
        scrollView.isScrollEnabled = false
        scrollView.addSubview(contentView)
        
        contentView.addSubviews(detailLabel, emailTextField, passwordTextField, rePasswordTextField, registerButton, appleSignInButton, facebookSignInButton)
        containerView.addSubview(showPasswordButton)
        reContainerView.addSubview(reShowPasswordButton)
        appleSignInButton.translatesAutoresizingMaskIntoConstraints = false
        
        detailLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        detailLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
        
        emailTextField.topAnchor.constraint(equalTo: detailLabel.bottomAnchor, constant: 50).isActive = true
        emailTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        emailTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 10).isActive = true
        passwordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        passwordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        rePasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 10).isActive = true
        rePasswordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        rePasswordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        rePasswordTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        registerButton.topAnchor.constraint(equalTo: rePasswordTextField.bottomAnchor, constant: 20).isActive = true
        registerButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        registerButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        appleSignInButton.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 50).isActive = true
        appleSignInButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        appleSignInButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        appleSignInButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        facebookSignInButton.topAnchor.constraint(equalTo: appleSignInButton.bottomAnchor, constant: 10).isActive = true
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
            let credential = OAuthProvider.credential(withProviderID: K.appleProviderID,
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            showLoading()
            viewModel.signInUserWith(with: credential)
        }
    }
}

extension RegisterViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        registerButtonTapped()
        return true
    }
}

extension RegisterViewController: RegisterViewModelDelegate {
    func handleCreateUserOutput(_ result: Result<Void, Error>) {
        
        switch result {
        case .success(_):
            presentAlert(title: "Welcome", message: "Account Succesfully Created", buttonTitle: "OK")
            viewModel.userCreated()
            
        case .failure(let failure):
            presentAlert(title: "Warning", message: failure.localizedDescription, buttonTitle: "OK")
        }
        
        dismissLoading()
    }
    
    func handleViewModelOutput(_ result: Result<Void, Error>) {
        switch result {
        case .success(_):
            openMainTabBarVc()
        case .failure(let failure):
            presentAlert(title: "Warning", message: failure.localizedDescription, buttonTitle: "OK")
        }
        
        dismissLoading()
    }
}
