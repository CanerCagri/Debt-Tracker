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
import FacebookCore


class LoginViewController: UIViewController {
    
    lazy var contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height + 150)
    
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
    
    let detailLabel = DTTitleLabel(textAlignment: .left, fontSize: 24, text: "Login Account")
    let emailTextField = DTTextField(placeholder: "Your Email", placeHolderSize: 15)
    let passwordTextField = DTTextField(placeholder: "Password", placeHolderSize: 15)
    let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
    let showPasswordButton = UIButton(type: .system)
    let loginButton = DTButton(title: "LOGIN", color: .systemPink, systemImageName: SFSymbols.checkMarkSymbol, size: 20)
    var forgetPasswordLabel = DTTitleLabel(textAlignment: .center, fontSize: 18, textColor: .systemGray2, text: "Forgot Password?")
    let dontHaveAccLabel = DTTitleLabel(textAlignment: .center, fontSize: 16, textColor: .label, text: "Don't have an account?")
    let registerLabel = DTTitleLabel(textAlignment: .center, fontSize: 18, textColor: .systemGray2, text: "REGISTER")
    var googleSignInButton = GIDSignInButton()
    var facebookLoginButton = DTFacebookSigninButton(iconCentered: false)
    var logoImageView = UIImageView()
    
    let viewModel = LoginViewModel()
    
    var isLoginTapped = false
    var isForgetPasswordTapped = false
    var isKeyboardAppear = false
    
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
        contentView.endEditing(true)
        
#if DEBUG
        emailTextField.text = "1@gmail.com"
        passwordTextField.text = "123456"
#endif
    }
    
    private func configureViewController() {
        if traitCollection.userInterfaceStyle == .dark {
            view.backgroundColor = Colors.darkModeColor
            contentView.backgroundColor = Colors.darkModeColor
            forgetPasswordLabel.textColor = .systemGray
            registerLabel.textColor = .systemGray
        } else {
            view.backgroundColor = Colors.lightModeColor
            contentView.backgroundColor = Colors.lightModeColor
        }
        
        if Auth.auth().currentUser != nil {
            showLoading()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1 ) { [weak self] in
                self?.openMainTabBarVc()
                self?.dismissLoading()
            }
        }
        
        passwordTextField.isSecureTextEntry = true
        passwordTextField.delegate = self
        emailTextField.delegate = self
        viewModel.delegate = self
        
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
        passwordTextField.leftView = leftPaddingView
        passwordTextField.leftViewMode = .always
        
        showPasswordButton.setImage(UIImage(systemName: SFSymbols.hidePasswordSymbol), for: .normal)
        showPasswordButton.frame = CGRect(x: -5, y: 0, width: 30, height: 30)
        showPasswordButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        
        passwordTextField.rightView = containerView
        passwordTextField.rightViewMode = .always
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        googleSignInButton.addTarget(self, action: #selector(signInWithGooglePressed), for: .touchUpInside)
        facebookLoginButton.addTarget(self, action: #selector(signInWithFacebookPressed), for: .touchUpInside)
        
        forgetPasswordLabel.isUserInteractionEnabled = true
        registerLabel.isUserInteractionEnabled = true
        let forgetPasswordTapGesture = UITapGestureRecognizer(target: self, action: #selector(showForgetPasswordPopup))
        forgetPasswordLabel.addGestureRecognizer(forgetPasswordTapGesture)
        
        let registerTapGesture = UITapGestureRecognizer(target: self, action: #selector(registerPagePresent))
        registerLabel.addGestureRecognizer(registerTapGesture)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        contentView.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil )
        
        NotificationCenter.default.addObserver(self, selector: #selector(signOutButton), name: .signOutButtonTapped, object: nil)
        
        NotificationCenter.default.addObserver(forName: .resetVcClosed, object: nil, queue: nil) { [weak self] (notification) in
            self?.isForgetPasswordTapped = false
        }
    }
    
    @objc func loginButtonTapped() {
        if let email = emailTextField.text, let password = passwordTextField.text {
            
            if isLoginTapped != true {
                showLoading()
                viewModel.signInUser(email: email, password: password)
            }
        }
    }
    
    @objc func signInWithGooglePressed() {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] signInResult, err in
            
            if let error = err {
                print(error.localizedDescription)
                return
            }
            
            guard let authentication = signInResult?.user, let idToken = authentication.idToken?.tokenString else { return }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken.tokenString)
            self?.showLoading()
            self?.viewModel.signInUserWith(with: credential)
        }
    }
    
    @objc func signInWithFacebookPressed() {
        LoginManager().logIn(permissions: [K.facebookPublicProfile, K.facebookEmail], from: self) { [weak self] result, error in
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
    
    @objc func signOutButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func openMainTabBarVc() {
        let tabBarVC = MainTabBarViewController()
        tabBarVC.navigationItem.hidesBackButton = true
        navigationController?.pushViewController(tabBarVC, animated: true)
        isLoginTapped = true
    }
    
    @objc func showForgetPasswordPopup() {
        if !isForgetPasswordTapped {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2 ) { [weak self] in
                let popupVc = ForgotPasswordVc()
                
                popupVc.modalTransitionStyle = .crossDissolve
                popupVc.modalPresentationStyle = .overFullScreen
                self?.present(popupVc, animated: true)
            }
            isForgetPasswordTapped = true
        }
    }
    
    @objc func registerPagePresent() {
        let registerVC = RegisterViewController()
        navigationController?.pushViewController(registerVC, animated: true)
    }
    
    @objc func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle()
        
        if passwordTextField.isSecureTextEntry {
            showPasswordButton.setImage(UIImage(systemName: SFSymbols.hidePasswordSymbol), for: .normal)
        } else {
            showPasswordButton.setImage(UIImage(systemName: SFSymbols.showPasswordSymbol), for: .normal)
        }
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
    
    private func applyConstraints() {
        view.addSubview(scrollView)
        scrollView.isScrollEnabled = false
        scrollView.addSubview(contentView)
        
        googleSignInButton.translatesAutoresizingMaskIntoConstraints = false
        googleSignInButton.style = .wide
        googleSignInButton.colorScheme = .light
        
        let underlineAttr = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        let forgetPasswordLabelString = NSAttributedString(string: "Forgot Password?", attributes: underlineAttr)
        let registerLabelString = NSAttributedString(string: "REGISTER", attributes: underlineAttr)
        
        forgetPasswordLabel.attributedText = forgetPasswordLabelString
        registerLabel.attributedText = registerLabelString
        
        contentView.addSubviews(detailLabel, emailTextField, passwordTextField, loginButton, forgetPasswordLabel, googleSignInButton, facebookLoginButton, dontHaveAccLabel, registerLabel)
        containerView.addSubview(showPasswordButton)
        
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
        
        loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20).isActive = true
        loginButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        loginButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        forgetPasswordLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        forgetPasswordLabel.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 15).isActive = true
        
        googleSignInButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 70).isActive = true
        googleSignInButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        googleSignInButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        googleSignInButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        facebookLoginButton.topAnchor.constraint(equalTo: googleSignInButton.bottomAnchor, constant: 10).isActive = true
        facebookLoginButton.leadingAnchor.constraint(equalTo: loginButton.leadingAnchor).isActive = true
        facebookLoginButton.trailingAnchor.constraint(equalTo: loginButton.trailingAnchor).isActive = true
        facebookLoginButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let registerLabelTopConstant: CGFloat = DeviceTypes.isiPhoneSE || DeviceTypes.isiPhone8PlusZoomed || DeviceTypes.isiPhone8Standard || DeviceTypes.isiPhone8Zoomed || DeviceTypes.isiPhone8PlusStandard ? 80 : 150
        
        registerLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        registerLabel.topAnchor.constraint(equalTo: facebookLoginButton.bottomAnchor, constant: registerLabelTopConstant).isActive = true
        
        dontHaveAccLabel.bottomAnchor.constraint(equalTo: registerLabel.topAnchor, constant: -5).isActive = true
        dontHaveAccLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        loginButtonTapped()
        return true
    }
}

extension LoginViewController: LoginViewModelDelegate {
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
