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
    
    // MARK: -- Bank Methods
    
    func createBank(name: String, detail: String, completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard let userEmail = Auth.auth().currentUser?.email else { return }
        
        db.collection(K.banks).addDocument(data: [K.email: userEmail,
                                                  K.name: name,
                                                  K.detail: detail,
                                                  K.date: Date().timeIntervalSince1970 ]) { error in
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
        
        db.collection(K.banks).order(by: K.date, descending: true).addSnapshotListener { querySnapShot, error in
            
            banks = []
            documentIds = []
            
            if let error = error {
                completion(.failure(error))
            } else {
                if let querySnapShotDocuments = querySnapShot?.documents {
                    for doc in querySnapShotDocuments {
                        let data = doc.data()
                        
                        if let email = data[K.email] as? String {
                            if email == Auth.auth().currentUser?.email {
                                
                                if let name = data[K.name] as? String, let detail = data[K.detail] as? String {
                                    
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
        let documentRef = db.collection(K.banks).document(documentId)
        
        documentRef.delete { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Succesfully removed")
            }
        }
    }
    
    // MARK: -- Credit Methods
    
    func fetchCredit(completion: @escaping(Result<CreditData, Error> )-> Void) {
        var banks: [CreditDetailModel] = []
        var documentIds: [String] = []
        
        banksListener = db.collection(K.credits).addSnapshotListener { querySnapShot, error in
            
            banks = []
            documentIds = []
            
            if let error = error {
                completion(.failure(error))
            } else {
                if let querySnapShotDocuments = querySnapShot?.documents {
                    for doc in querySnapShotDocuments {
                        let data = doc.data()
                        
                        if let email = data[K.email] as? String {
                            if email == Auth.auth().currentUser?.email {
                                if let name = data[K.name] as? String,
                                   let detail = data[K.detail] as? String,
                                   let entryDebt = data[K.entryDebt] as? String,
                                   let installmentCount = data[K.installmentCount] as? Int,
                                   let paidCount = data[K.paidCount] as? Int,
                                   let monthlyInstallment = data[K.monthlyInstallment] as? String,
                                   let firstInstallmentDate = data[K.firstInstallmentDate] as? String,
                                   let currentInstallmentDate = data[K.currentInstallmentDate] as? String,
                                   let totalDebt = data[K.totalDebt] as? String,
                                   let interestRate = data[K.interestRate] as? Double,
                                   let remainingDebt = data[K.remainingDebt] as? String,
                                   let paidDebt = data[K.paidDebt] as? String,
                                   let currency = data[K.currency] as? String,
                                   let locale = data[K.locale] as? String {
                                    
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
    
    func stopFetchingBank() {
        banksListener?.remove()
    }
    
    func createCredit(creditModel: CreditDetailModel, completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard let userEmail = Auth.auth().currentUser?.email else { return }
        
        db.collection(K.credits).addDocument(data: [K.email: userEmail,
                                                    K.name: creditModel.name,
                                                    K.detail: creditModel.detail,
                                                    K.entryDebt: creditModel.entryDebt,
                                                    K.installmentCount: creditModel.installmentCount,
                                                    K.paidCount: creditModel.paidCount,
                                                    K.monthlyInstallment: creditModel.monthlyInstallment,
                                                    K.firstInstallmentDate: creditModel.firstInstallmentDate,
                                                    K.currentInstallmentDate: creditModel.currentInstallmentDate,
                                                    K.totalDebt: creditModel.totalDebt,
                                                    K.interestRate: creditModel.interestRate,
                                                    K.remainingDebt: creditModel.remainingDebt,
                                                    K.paidDebt: creditModel.paidDebt,
                                                    K.createDate: Date().timeIntervalSince1970,
                                                    K.currency: creditModel.currency,
                                                    K.locale: creditModel.locale ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func editCredit(documentId: String, viewModel: CreditDetailModel, completion: @escaping (Result<Void, Error>) -> Void) {
        
        let documentRef = db.collection(K.credits).document(documentId)
        documentRef.setData([K.email: viewModel.email,
                             K.name: viewModel.name,
                             K.detail: viewModel.detail,
                             K.entryDebt: viewModel.entryDebt,
                             K.installmentCount: viewModel.installmentCount,
                             K.paidCount: viewModel.paidCount,
                             K.monthlyInstallment: viewModel.monthlyInstallment,
                             K.firstInstallmentDate: viewModel.firstInstallmentDate,
                             K.currentInstallmentDate: viewModel.currentInstallmentDate,
                             K.totalDebt: viewModel.totalDebt,
                             K.interestRate: viewModel.interestRate,
                             K.remainingDebt: viewModel.remainingDebt,
                             K.paidDebt: viewModel.paidDebt,
                             K.currency: viewModel.currency,
                             K.locale: viewModel.locale ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
        
    }
    
    func deleteCredit(documentId: String) {
        let documentRef = db.collection(K.credits).document(documentId)
        
        documentRef.delete { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Succesfully removed")
            }
        }
    }
}
