//
//  CreditsMainViewModel.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 23.03.2023.
//

import Foundation
import Firebase


class CreditsMainViewModel: CreditsMainViewModelProtocol {

    var delegate: CreditsMainViewModelDelegate?
    var banks: [BankDetails] = []
    var documentIds: [String] = []
    
    func fetchBanks() {
        FirestoreManager.shared.fetchBanks { [weak self] result in
            self?.delegate?.handleViewModelOutput(result)
        }
    }

    func removeBank(documentId: String) {
        FirestoreManager.shared.deleteBank(documentId: documentId)
    }
    
    func removeAccount() {
        guard let user = Auth.auth().currentUser else { return }
        do {
            try Auth.auth().signOut()
            
        } catch let signOutError as NSError {
            print("Error when signing out: %@", signOutError)
        }
        
        AuthManager.shared.deleteAccount(user: user)
        
    }
    
    func deleteAccountDocuments() {
        AuthManager.shared.deleteAccountDocuments(documentName: K.banks)
        AuthManager.shared.deleteAccountDocuments(documentName: K.credits)
    }
    
    func userSignout() {
        do {
            try Auth.auth().signOut()
            FirestoreManager.shared.stopFetchingBank()
            NotificationCenter.default.post(name: .signOutButtonTapped, object: nil)
            
        } catch let signOutError as NSError {
            print("Error when signing out: %@", signOutError)
        }
    }
}
