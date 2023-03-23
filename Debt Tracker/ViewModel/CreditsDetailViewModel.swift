//
//  CreditsDetailViewModel.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 23.03.2023.
//

import Foundation


class CreditsDetailViewModel: CreditsDetailViewModelProtocol {
    
    var delegate: CreditsDetailViewlModelDelegate?
    
    func editCredit(documentId: String, viewModel: CreditDetailModel) {
        FirestoreManager.shared.editCredit(documentId: documentId, viewModel: viewModel) { [weak self] result in
            self?.delegate?.handleViewModelOutput(result)
        }
    }
}
