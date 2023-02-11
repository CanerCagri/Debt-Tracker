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
    let saveButton = DTButton(title: "Save", color: .systemPink, systemImageName: "square.and.arrow.down")
    
    let nameTextField = DTTextField(placeholder: "Enter Name", placeHolderSize: 15)
    let detailTextField = DTTextField(placeholder: "Enter Detail", placeHolderSize: 15)
    
    private var closeButton: UIButton = {
        var button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.imageView?.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.imageView?.widthAnchor.constraint(equalToConstant: 44).isActive = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        applyConstraints()
    }
    
    private func configureViewController() {
        titleLabel.text = "Add Bank"
        view.backgroundColor = UIColor.systemGray.withAlphaComponent(0.5)
        view.frame = UIScreen.main.bounds
        
        closeButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
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
        
        FirestoreManager.shared.createBank(name: name, detail: detail) { [weak self] result in
            switch result {
            case .success(_):
                self?.dismissVC()
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }
    
    @objc func dismissVC() {
        NotificationCenter.default.post(Notification(name: Notification.Name("popupButtonTapped"), userInfo: nil))
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
        
        containerView.addSubviews(titleLabel, closeButton, saveButton, nameTextField, detailTextField)
        
        containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.82).isActive = true
        containerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.32).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        
        closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 2).isActive = true
        closeButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 2).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        
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
