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
    let emailTextField = DTTextField(placeholder: "Enter Email", placeHolderSize: 15)
    let resetButton = DTButton(title: "RESET PASSWORD", color: .systemPink, systemImageName: "arrow.clockwise", size: 20)
    let closeButton = DTButton(title: "CLOSE", color: UIColor.systemGray.withAlphaComponent(0.5), systemImageName: "xmark", size: 20)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        applyConstraints()
    }
    
    private func configureViewController() {
        view.backgroundColor = UIColor.systemGray.withAlphaComponent(0.5)
        view.frame = UIScreen.main.bounds
        
        closeButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    @objc func saveButtonTapped() {
        if let email = emailTextField.text {
            
            AuthManager.shared.resetPassword(email: email) { [weak self] result in
                switch result {
                case .success(_):
                    print("succesfully sended mail")
                case .failure(let failure):
                    self?.presentAlert(title: "Warning", message: failure.localizedDescription, buttonTitle: "OK")
                }
            }
        }
    }
    
    @objc func dismissVC() {
        NotificationCenter.default.post(Notification(name: Notification.Name("resetCloseTapped"), userInfo: nil))
        animateOut()
    }
    
    func animateOut() {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseIn) { [weak self] in
            self?.containerView.transform = CGAffineTransform(translationX: 0, y: -(self?.view.frame.height)!)
            self?.view.alpha = 0
        } completion: { complete in
            if complete {
                self.view.removeFromSuperview()
            }
        }
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
        containerView.backgroundColor = .systemGray5
        
        let totalWidth = view.frame.width
        let textFieldWidth = totalWidth / 1.5
        
        containerView.addSubviews(titleLabel, emailTextField, resetButton, closeButton)
        
        containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.82).isActive = true
        containerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.30).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        
        emailTextField.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        emailTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        emailTextField.widthAnchor.constraint(equalToConstant: textFieldWidth ).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        resetButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        resetButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 10).isActive = true
        resetButton.widthAnchor.constraint(equalToConstant: textFieldWidth).isActive = true
        resetButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        closeButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        closeButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: textFieldWidth).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
}
