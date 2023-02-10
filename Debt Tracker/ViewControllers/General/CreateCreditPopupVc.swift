//
//  CreateCreditPopupVc.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 3.02.2023.
//

import UIKit
import Firebase

class CreateCreditPopupVc: UIViewController {
    
    let db = Firestore.firestore()
    
    private let containerView = DTContainerView()
    
    let titleLabel = DTTitleLabel(textAlignment: .center, fontSize: 18, textColor: .label)
    let cancelButton = DTButton(title: "Cancel", color: .systemPink, systemImageName: "xmark.circle.fill")
    let saveButton = DTButton(title: "Save", color: .systemPink, systemImageName: "square.and.arrow.down")
    
    let nameTextField = DTTextField(placeholder: "Enter Name", placeHolderSize: 15)
    
    let detailTextField = DTTextField(placeholder: "Enter Detail", placeHolderSize: 15)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        applyConstraints()
    }
    
    private func configureViewController() {
        titleLabel.text = "Add Bank"
        view.backgroundColor = UIColor.systemGray.withAlphaComponent(0.5)
        view.frame = UIScreen.main.bounds
        
        cancelButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    @objc func saveButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty else {
            presentAlert(title: "Warning", message: "Please enter a Name", buttonTitle: "Ok")
            return
        }
        guard let detail = detailTextField.text, !detail.isEmpty else {
            presentAlert(title: "Warning", message: "Please enter Detail", buttonTitle: "Ok")
            return
        }
        
        guard let userEmail = Auth.auth().currentUser?.email else { return }
        
        db.collection("banks").addDocument(data: ["email": userEmail,
                                                  "name": name,
                                                  "detail": detail,
                                                  "date": Date().timeIntervalSince1970 ]){ error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.dismissVC()
            }
        }
    }
    
    @objc func dismissVC() {
        NotificationCenter.default.post(Notification(name: Notification.Name("popupButtonTapped"), userInfo: nil))
        animateOut()
    }
    
    func animateOut() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseIn) { [weak self] in
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
        
        containerView.addSubviews(titleLabel, cancelButton, saveButton, nameTextField, detailTextField)
        
        containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.82).isActive = true
        containerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.32).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        
        cancelButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 5).isActive = true
        cancelButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5).isActive = true
        
        saveButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5).isActive = true
        saveButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -5).isActive = true
        
        nameTextField.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        nameTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        nameTextField.widthAnchor.constraint(equalToConstant: textFieldWidth ).isActive = true
        nameTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        detailTextField.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        detailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 10).isActive = true
        detailTextField.widthAnchor.constraint(equalToConstant: textFieldWidth).isActive = true
        detailTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
}
