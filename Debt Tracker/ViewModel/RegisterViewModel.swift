//
//  RegisterViewModel.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 23.03.2023.
//

import Foundation
import Firebase


class RegisterViewModel: RegisterViewModelProtocol {
    
    var delegate: RegisterViewModelDelegate?
    
    func createUser(email: String, password: String) {
        AuthManager.shared.createUser(email: email, password: password) { [weak self] result in
            self?.delegate?.handleCreateUserOutput(result)
        }
    }
    
    func signInUserWith(with credential: AuthCredential) {
        AuthManager.shared.signInUserWith(with: credential) { [weak self] result in
            self?.delegate?.handleViewModelOutput(result)
        }
    }
    
    func userCreated() {
        do {
            try Auth.auth().signOut()
            NotificationCenter.default.post(name: .signOutButtonTapped, object: nil)
            
        } catch let signOutError as NSError {
            print("Error when signing out: %@", signOutError)
        }
    }
}
