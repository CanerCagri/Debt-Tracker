//
//  AuthManager.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 12.02.2023.
//

import Foundation
import Firebase
import FirebaseAuth

class AuthManager {
    
    static let shared = AuthManager()
    
    // MARK: -- Account Methods
    
    func createUser(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func signInUser(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func signInUserWith(with credential: AuthCredential, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func resetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func deleteAccount(user: User?) {
        
        guard let user = user else { return}
        
        user.delete { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("User succesfully deleted.")
            }
        }
    }
    
    func deleteAccountDocuments(documentName: String) {
        
        guard let currentUserEmail = Auth.auth().currentUser?.email else { return }
        
        let db = Firestore.firestore()
        let ref = db.collection(documentName)
        

        ref.getDocuments { (snapshot, error) in
            if error == nil {
                guard let documents = snapshot?.documents else {return }
                for document in documents {
                    let email = document.data()[K.email] as? String ?? ""
                    if email == currentUserEmail {
                        document.reference.delete()
                    }
                }
            } else {
                print(error!.localizedDescription)
            }
        }
    }
}
