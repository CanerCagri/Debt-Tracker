//
//  ForgotPasswordVc.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 12.02.2023.
//

import UIKit
import Firebase

class ForgotPasswordVc: UIViewController {
    
    private let containerView = DTContainerView()
    let titleLabel = DTTitleLabel(textAlignment: .center, fontSize: 18, textColor: .label, text: "Reset Password")
    let emailTextField = DTTextField(placeholder: "Enter Email", placeHolderSize: 15, cornerRadius: 14)
    let resetButton = DTButton(title: "RESET PASSWORD", color: .systemPink, systemImageName: SFSymbols.resetSymbol, size: 20)
    private var closeButton = DTCloseButton()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        applyConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emailTextField.text = ""
        view.endEditing(true)
    }
    
    private func configureViewController() {
        containerView.setBackgroundColor()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        view.frame = UIScreen.main.bounds
        hideKeyboardWheTappedAround()
        
        emailTextField.delegate = self
        closeButton.addTarget(self, action: #selector(dismissVc), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
    }
    
    @objc func resetButtonTapped() {
        if let email = emailTextField.text {
            showLoading()
            AuthManager.shared.resetPassword(email: email) { [weak self] result in
                switch result {
                case .success(_):
                    self?.presentAlert(title: "Mail Sended", message: "Password Reset Mail Succesfully Sended.", buttonTitle: "OK")
                case .failure(let failure):
                    self?.presentAlert(title: "Warning", message: failure.localizedDescription, buttonTitle: "OK")
                }
                self?.dismissLoading()
            }
        }
    }
    
    @objc func dismissVc() {
        NotificationCenter.default.post(Notification(name: .resetVcClosed, userInfo: nil))
        dismiss(animated: true)
    }

    func animateIn() {
        self.containerView.transform = CGAffineTransform(translationX: 0, y: -self.view.frame.height)
        self.view.alpha = 0
        
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseIn) {
            self.containerView.transform = .identity
            self.view.alpha = 1
        }
    }
    
    private func applyConstraints() {
        animateIn()
        view.addSubview(containerView)
        
        let totalWidth = view.frame.width
        let textFieldWidth = totalWidth / 1.5
        
        containerView.addSubviews(titleLabel, emailTextField, resetButton, closeButton)
        
        containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.82).isActive = true
        containerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.28).isActive = true
        
        closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 2).isActive = true
        closeButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 2).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        
        resetButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        resetButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 25).isActive = true
        resetButton.widthAnchor.constraint(equalToConstant: textFieldWidth).isActive = true
        resetButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        emailTextField.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        emailTextField.bottomAnchor.constraint(equalTo: resetButton.topAnchor, constant: -10).isActive = true
        emailTextField.widthAnchor.constraint(equalToConstant: textFieldWidth ).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
}

extension ForgotPasswordVc: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        resetButtonTapped()
        return true
    }
}
