//
//  CreditsViewModel.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 23.03.2023.
//

import Foundation


class CreditsViewModel: CreditsViewModelProtocol {
    
    var delegate: CreditsViewModelDelegate?
    var credits: [CreditDetailModel] = []
    var documentIds: [String] = []
    
    func fetchCredits() {
        FirestoreManager.shared.fetchCredit { [weak self] result in
            self?.delegate?.handleViewModelOutput(result)
        }
    }
    
    func removeCredits(documentId: String) {
        FirestoreManager.shared.deleteCredit(documentId: documentId)
    }
    
    func numberOfRowsInSection() -> Int{
        return credits.count
    }
}
