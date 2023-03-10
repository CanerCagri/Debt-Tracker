//
//  CreateCreditPopupVc.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 3.02.2023.
//

import UIKit
import Firebase

class CreateBankPopupVc: UIViewController {
    
    private let containerView = DTContainerView()
    let titleLabel = DTTitleLabel(textAlignment: .center, fontSize: 18, textColor: .label, text: "Add Bank")
    let saveButton = DTButton(title: "SAVE", color: .systemPink, systemImageName: "square.and.arrow.down", size: 20)
    let nameTextField = DTTextField(placeholder: "Bank Name", placeHolderSize: 15)
    let detailTextField = DTTextField(placeholder: "Detail", placeHolderSize: 15)
    private var closeButton = DTCloseButton()
    
    let db = Firestore.firestore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        applyConstraints()
    }
    
    private func configureViewController() {
        view.backgroundColor = UIColor.systemGray.withAlphaComponent(0.5)
        view.frame = UIScreen.main.bounds
        
        closeButton.addTarget(self, action: #selector(animateOut), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
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
                self?.animateOut()
            case .failure(let failure):
                self?.presentAlert(title: "Warning", message: failure.localizedDescription, buttonTitle: "OK")
            }
        }
    }
    
    @objc func animateOut() {
        NotificationCenter.default.post(Notification(name: Notification.Name("popupButtonTapped"), userInfo: nil))
        
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
        containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.82).isActive = true
        containerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.30).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        
        closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 2).isActive = true
        closeButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 2).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        
        let nameTextFieldTopConstant: CGFloat = DeviceTypes.isiPhoneSE || DeviceTypes.isiPhone8PlusZoomed || DeviceTypes.isiPhone8Standard || DeviceTypes.isiPhone8Zoomed || DeviceTypes.isiPhone8PlusStandard ? 25 : 50
        
        nameTextField.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: nameTextFieldTopConstant).isActive = true
        nameTextField.widthAnchor.constraint(equalToConstant: textFieldWidth ).isActive = true
        nameTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        detailTextField.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        detailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 10).isActive = true
        detailTextField.widthAnchor.constraint(equalToConstant: textFieldWidth).isActive = true
        detailTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let saveButtonBottomConstant: CGFloat = DeviceTypes.isiPhoneSE || DeviceTypes.isiPhone8PlusZoomed || DeviceTypes.isiPhone8Standard || DeviceTypes.isiPhone8Zoomed || DeviceTypes.isiPhone8PlusStandard ? -5 : -12
        
        saveButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        saveButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: saveButtonBottomConstant).isActive = true
        saveButton.widthAnchor.constraint(equalToConstant: textFieldWidth).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
}
