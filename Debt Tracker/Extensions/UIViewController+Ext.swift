//
//  UIViewController+Ext.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 28.01.2023.
//

import UIKit

fileprivate var containerView: UIView!

extension UIViewController {
    
    func presentAlert(title: String, message: String, buttonTitle: String) {
        DispatchQueue.main.async {
            let alertVC = DTAlertViewController(alertTitle: title, message: message, buttonTitle: buttonTitle)
            alertVC.modalTransitionStyle = .crossDissolve
            alertVC.modalPresentationStyle = .overFullScreen
            self.present(alertVC, animated: true)
        }
    }
    
    func presentDefaultError() {
        let alertVC = DTAlertViewController(alertTitle: "Something Went Wrong",
                                            message: "Please try again",
                                            buttonTitle: "Ok")
        alertVC.modalTransitionStyle = .crossDissolve
        alertVC.modalPresentationStyle = .overFullScreen
        present(alertVC, animated: true)
    }
    
    func showLoading() {
        containerView = UIView(frame: view.bounds)
        view.addSubview(containerView)
        containerView.backgroundColor = .systemBackground
        containerView.alpha = 0
        
        UIView.animate(withDuration: 0.25) {
            containerView.alpha = 0.8
        }
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        containerView.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        
        activityIndicator.startAnimating()
    }
    
    func dismissLoading() {
        DispatchQueue.main.async {
            containerView.removeFromSuperview()
            containerView = nil
        }
    }
    
    func showEmptyState(message: String, view: UIView) {
        let emptyState = DTEmptyStateView(message: message)
        emptyState.frame = view.bounds
        view.addSubview(emptyState)
    }
    
    func hideKeyboardWheTappedAround() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
}
