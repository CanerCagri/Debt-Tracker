//
//  AddCreditViewModel.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 23.03.2023.
//

import Foundation


class AddCreditViewModel: AddCreditViewModelProtocol {
    
    var delegate: AddCreditViewlModelDelegate?
    
    func addCredit(creditModel: CreditDetailModel) {
        FirestoreManager.shared.createCredit(creditModel: creditModel) { [weak self] result in
            self?.delegate?.handleViewModelOutput(result)
        }
    }
}
