//
//  LoginViewModel.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 23.03.2023.
//

import Foundation
import Firebase


class LoginViewModel: LoginViewModelProtocol{
    
    var delegate: LoginViewModelDelegate?
    
    func signInUser(email: String, password: String) {
        AuthManager.shared.signInUser(email: email, password: password) { [weak self] result in
            self?.delegate?.handleViewModelOutput(result)
        }
    }
    
    func signInUserWith(with credential: AuthCredential) {
        AuthManager.shared.signInUserWith(with: credential) { [weak self] result in
            self?.delegate?.handleViewModelOutput(result)
        }
    }
}
