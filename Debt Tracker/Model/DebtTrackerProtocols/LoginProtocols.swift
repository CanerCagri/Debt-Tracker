//
//  LoginProtocols.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 23.03.2023.
//

import Foundation
import Firebase

protocol LoginViewModelProtocol {
    var delegate: LoginViewModelDelegate? {get set}
    func signInUser(email: String, password: String)
    func signInUserWith(with credential: AuthCredential)
}

protocol LoginViewModelDelegate {
    func handleViewModelOutput (_ result: Result<Void, Error>)
}

protocol RegisterViewModelProtocol {
    var delegate: RegisterViewModelDelegate? {get set}
    func createUser(email: String, password: String)
    func signInUserWith(with credential: AuthCredential)
}

protocol RegisterViewModelDelegate {
    func handleCreateUserOutput(_ result: Result<Void, Error>)
    func handleViewModelOutput(_ result: Result<Void, Error>)
}

protocol ResetPasswordViewModelProtocol {
    var delegate: ResetPasswordViewModelDelegate? {get set}
    func resetPassword(email: String)
}

protocol ResetPasswordViewModelDelegate {
    func handleViewModelOutput(_ result: Result<Void, Error>)
}
