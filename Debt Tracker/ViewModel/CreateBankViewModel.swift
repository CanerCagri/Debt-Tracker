//
//  CreateBankViewModel.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 23.03.2023.
//

import Foundation


class CreateBankViewModel: CreateBankViewModelProtocol {
    
    var delegate: CreateBankViewModelDelegate?
    
    func addBank(name: String, detail: String) {
        FirestoreManager.shared.createBank(name: name, detail: detail) { [weak self] result in
            self?.delegate?.handleViewModelOutput(result)
        }
    }
}
