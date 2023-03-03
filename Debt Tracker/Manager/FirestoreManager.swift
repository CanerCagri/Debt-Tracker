//
//  PersistenceManager.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 27.01.2023.
//

import UIKit
import CoreData
import Firebase

struct BankData {
    let bankDetails: [BankDetails]
    let stringArray: [String]
}

struct CreditData {
    let creditDetails: [CreditDetailModel]
    let stringArray: [String]
}

class FirestoreManager {
    
    static let shared = FirestoreManager()
    let db = Firestore.firestore()
    var banksListener: ListenerRegistration?
    
    
    func createBank(name: String, detail: String, completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard let userEmail = Auth.auth().currentUser?.email else { return }
        
        db.collection("banks").addDocument(data: ["email": userEmail,
                                                  "name": name,
                                                  "detail": detail,
                                                  "date": Date().timeIntervalSince1970 ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func fetchBanks(completion: @escaping(Result<BankData, Error> )-> Void) {
        var banks: [BankDetails] = []
        var documentIds: [String] = []
        
        db.collection("banks").order(by: "date", descending: true).addSnapshotListener { querySnapShot, error in
            
            banks = []
            documentIds = []
            
            if let error = error {
                completion(.failure(error))
            } else {
                if let querySnapShotDocuments = querySnapShot?.documents {
                    for doc in querySnapShotDocuments {
                        let data = doc.data()
                        
                        if let email = data["email"] as? String {
                            if email == Auth.auth().currentUser?.email {
                                
                                if let name = data["name"] as? String, let detail = data["detail"] as? String {
                                    
                                    let bankModel = BankDetails(name: name, detail: detail, email: email)
                                    banks.append(bankModel)
                                    documentIds.append(doc.documentID)
                                }
                            }
                        }
                    }
                }
                completion(.success(BankData(bankDetails: banks, stringArray: documentIds)))
            }
        }
    }
    
    func deleteBank(documentId: String) {
        let documentRef = db.collection("banks").document(documentId)
        
        documentRef.delete { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Succesfully removed")
            }
        }
    }
    
    func fetchCredit(completion: @escaping(Result<CreditData, Error> )-> Void) {
        var banks: [CreditDetailModel] = []
        var documentIds: [String] = []
        
        banksListener = db.collection("credits").addSnapshotListener { querySnapShot, error in
            
            banks = []
            documentIds = []
            
            if let error = error {
                completion(.failure(error))
            } else {
                if let querySnapShotDocuments = querySnapShot?.documents {
                    for doc in querySnapShotDocuments {
                        let data = doc.data()
                        
                        if let email = data["email"] as? String {
                            if email == Auth.auth().currentUser?.email {
                                if let name = data["name"] as? String,
                                   let detail = data["detail"] as? String,
                                   let entryDebt = data["entryDebt"] as? String,
                                   let installmentCount = data["installmentCount"] as? Int,
                                   let paidCount = data["paidCount"] as? Int,
                                   let monthlyInstallment = data["monthlyInstallment"] as? String,
                                   let firstInstallmentDate = data["firstInstallmentDate"] as? String,
                                   let currentInstallmentDate = data["currentInstallmentDate"] as? String,
                                   let totalDebt = data["totalDebt"] as? String,
                                   let interestRate = data["interestRate"] as? Double,
                                   let remainingDebt = data["remainingDebt"] as? String,
                                   let paidDebt = data["paidDebt"] as? String,
                                   let currency = data["currency"] as? String,
                                   let locale = data["locale"] as? String {
                                    
                                    let creditModel = CreditDetailModel(name: name, detail: detail, entryDebt: entryDebt, installmentCount: installmentCount, paidCount: paidCount, monthlyInstallment: monthlyInstallment, firstInstallmentDate: firstInstallmentDate, currentInstallmentDate: currentInstallmentDate, totalDebt: totalDebt, interestRate: interestRate, remainingDebt: remainingDebt, paidDebt: paidDebt, email: email, currency: currency, locale: locale)
                                    banks.append(creditModel)
                                    documentIds.append(doc.documentID)
                                }
                            }
                        }
                    }
                }
                completion(.success(CreditData(creditDetails: banks, stringArray: documentIds)))
            }
        }
    }
    
    func stopFetchingCredit() {
        banksListener?.remove()
    }
    
    func createCredit(creditModel: CreditDetailModel, completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard let userEmail = Auth.auth().currentUser?.email else { return }
        
        db.collection("credits").addDocument(data: ["email": userEmail,
                                                    "name": creditModel.name,
                                                    "detail": creditModel.detail,
                                                    "entryDebt": creditModel.entryDebt,
                                                    "installmentCount": creditModel.installmentCount,
                                                    "paidCount": creditModel.paidCount,
                                                    "monthlyInstallment": creditModel.monthlyInstallment,
                                                    "firstInstallmentDate": creditModel.firstInstallmentDate,
                                                    "currentInstallmentDate": creditModel.currentInstallmentDate,
                                                    "totalDebt": creditModel.totalDebt,
                                                    "interestRate": creditModel.interestRate,
                                                    "remainingDebt": creditModel.remainingDebt,
                                                    "paidDebt": creditModel.paidDebt,
                                                    "createDate": Date().timeIntervalSince1970,
                                                    "currency": creditModel.currency,
                                                    "locale": creditModel.locale ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func editCredit(documentId: String, viewModel: CreditDetailModel, completion: @escaping (Result<Void, Error>) -> Void) {
        
        let documentRef = db.collection("credits").document(documentId)
        documentRef.setData(["email": viewModel.email,
                             "name": viewModel.name,
                             "detail": viewModel.detail,
                             "entryDebt": viewModel.entryDebt,
                             "installmentCount": viewModel.installmentCount,
                             "paidCount": viewModel.paidCount,
                             "monthlyInstallment": viewModel.monthlyInstallment,
                             "firstInstallmentDate": viewModel.firstInstallmentDate,
                             "currentInstallmentDate": viewModel.currentInstallmentDate,
                             "totalDebt": viewModel.totalDebt,
                             "interestRate": viewModel.interestRate,
                             "remainingDebt": viewModel.remainingDebt,
                             "paidDebt": viewModel.paidDebt,
                             "currency": viewModel.currency,
                             "locale": viewModel.locale ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
        
    }
    
    func deleteCredit(documentId: String) {
        let documentRef = db.collection("credits").document(documentId)
        
        documentRef.delete { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Succesfully removed")
            }
        }
    }
}
