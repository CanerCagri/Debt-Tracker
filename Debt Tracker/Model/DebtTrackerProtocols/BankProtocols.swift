//
//  DebtTrackerProtocols.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 23.03.2023.
//

import Foundation
import Firebase

protocol CreditsMainViewModelProtocol {
    var delegate: CreditsMainViewModelDelegate? {get set}
    func fetchBanks()
    func removeAccount()
    func deleteAccountDocuments()
    func removeBank(documentId: String)
}

protocol CreditsMainViewModelDelegate {
    func handleViewModelOutput (_ result: Result<BankData, Error>)
}

protocol CreateBankViewModelProtocol {
    var delegate: CreateBankViewModelDelegate? {get set}
    func addBank(name: String, detail: String)
}

protocol CreateBankViewModelDelegate {
    func handleViewModelOutput (_ result: Result<Void, Error>)
}
