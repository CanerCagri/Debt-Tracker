//
//  PersistenceManager.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 27.01.2023.
//

import UIKit
import CoreData


class PersistenceManager {
    
    enum DatabaseError: String, Error {
        case failedToDataSave = "Failed to save data. Please try again."
        case failedToFetchData = "Failed to fetch data. Please try again."
        case failedToDeleteData = "Failed to deleting data. Please try again."
    }
    
    static let shared = PersistenceManager()
    
    func createWithModel(model: CreditDetailModel, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let context = appDelegate.persistentContainer.viewContext
        let item = CreditDetail(context: context)
        
        item.id = model.id
        item.name = model.name
        item.detail = model.detail
        item.entry_debt = Int32(model.entryDebt)
        item.monthly_installment = model.monthlyInstallment
        item.installment_count = Int32(model.installmentCount)
        item.paid_installment_count = Int32(model.paidCount)
        item.first_installment = model.firstInstallmentDate
        item.interest_rate = model.interestRate
        item.total_payment = model.totalDebt
        item.remaining_debt = model.remainingDebt
        item.paid_debt = model.paidDebt
        item.current_installment = model.currentInstallmentDate
        
        do {
            try context.save()
            completion(.success(()))
        } catch {
            completion(.failure(DatabaseError.failedToDataSave))
        }
    }
    
//    func createBank(model: CreditDetailsModel, completion: @escaping (Result<Void, Error>) -> Void) {
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
//
//        let context = appDelegate.persistentContainer.viewContext
//        let item = CreditDetails(context: context)
//
//        item.id = model.id
//        item.name = model.name
//        item.detail = model.detail
//
//        do {
//            try context.save()
//            completion(.success(()))
//        } catch {
//            completion(.failure(DatabaseError.failedToDataSave))
//        }
//    }
    
    func fetchCredits(completion: @escaping(Result<[CreditDetail], Error> )-> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let context = appDelegate.persistentContainer.viewContext
        let request: NSFetchRequest<CreditDetail>
        request = CreditDetail.fetchRequest()
        
        do {
            let credits = try context.fetch(request)
            completion(.success(credits))
            
        } catch {
            completion(.failure(DatabaseError.failedToFetchData))
        }
    }
    
    func fetchBanks(completion: @escaping(Result<[CreditDetails], Error> )-> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let context = appDelegate.persistentContainer.viewContext
        let request: NSFetchRequest<CreditDetails>
        request = CreditDetails.fetchRequest()
        
        do {
            let banks = try context.fetch(request)
            completion(.success(banks))
            
        } catch {
            completion(.failure(DatabaseError.failedToFetchData))
        }
    }
    
    func deleteCreditWith(model: CreditDetail, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let context = appDelegate.persistentContainer.viewContext
        context.delete(model)
        
        do {
            try context.save()
            completion(.success(()))
        } catch {
            completion(.failure(DatabaseError.failedToDeleteData))
        }
    }
    
//    func deleteBankWith(model: CreditDetails, completion: @escaping (Result<Void, Error>) -> Void) {
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
//        
//        let context = appDelegate.persistentContainer.viewContext
//        context.delete(model)
//        
//        do {
//            try context.save()
//            completion(.success(()))
//        } catch {
//            completion(.failure(DatabaseError.failedToDeleteData))
//        }
//    }
    
    func editCreditDetails(model: CreditDetailModel) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let context = appDelegate.persistentContainer.viewContext
        
        let id = model.id
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CreditDetail")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)

        do {
            let result = try context.fetch(fetchRequest)
            if let entity = result.first as? CreditDetail {
                // Update the properties of the entity
                entity.first_installment = model.firstInstallmentDate
                entity.remaining_debt = model.remainingDebt
                entity.paid_installment_count = Int32(model.paidCount)
                entity.paid_debt = model.paidDebt
                entity.current_installment = model.currentInstallmentDate
                // Save the managed object context
                try context.save()
            }
        } catch {
            print("Error fetching data: \(error)")
        }
    }
}
