//
//  CreditProtocols.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 23.03.2023.
//

import Foundation

protocol CreditsViewModelProtocol {
    var delegate: CreditsViewModelDelegate? {get set}
    func fetchCredits()
    func removeCredits(documentId: String)
}

protocol CreditsViewModelDelegate {
    func handleViewModelOutput (_ result: Result<CreditData, Error>)
}

protocol AddCreditViewModelProtocol {
    var delegate: AddCreditViewlModelDelegate? {get set}
    func addCredit(creditModel: CreditDetailModel)
}

protocol AddCreditViewlModelDelegate {
    func handleViewModelOutput (_ result: Result<Void, Error>)
}

protocol CreditsDetailViewModelProtocol {
    var delegate: CreditsDetailViewlModelDelegate? {get set}
    func editCredit(documentId: String, viewModel: CreditDetailModel)
}

protocol CreditsDetailViewlModelDelegate {
    func handleViewModelOutput (_ result: Result<Void, Error>)
}
