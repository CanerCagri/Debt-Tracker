//
//  UIViewController+Ext.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 28.01.2023.
//

import UIKit

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
}
