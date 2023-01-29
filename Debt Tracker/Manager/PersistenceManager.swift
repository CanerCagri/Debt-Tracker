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
    
    func downloadWithModel(model: CreditModel, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let context = appDelegate.persistentContainer.viewContext
        let item = CreditItems(context: context)
        
        item.id = model.id
        item.name = model.name
        item.current_debt = Int32(model.currentDebt)
        item.entry_debt = Int32(model.entryDebt)
        item.payment_date = model.paymentDate
        item.montly_debt = model.monthlyDebt
        item.remaining_debt = model.remainingDebt
        item.paid_count = Int32(model.paidCount)
        
        
        do {
            try context.save()
            completion(.success(()))
        } catch {
            completion(.failure(DatabaseError.failedToDataSave))
        }
    }
    
    func fetchCredits(completion: @escaping(Result<[CreditItems], Error> )-> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let context = appDelegate.persistentContainer.viewContext
        let request: NSFetchRequest<CreditItems>
        request = CreditItems.fetchRequest()
        
        do {
            let credits = try context.fetch(request)
            completion(.success(credits))
            
        } catch {
            completion(.failure(DatabaseError.failedToFetchData))
        }
    }
    
    func deleteCreditWith(model: CreditItems, completion: @escaping (Result<Void, Error>) -> Void) {
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
    
    func editCreditDetails(model: CreditModel) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let context = appDelegate.persistentContainer.viewContext
        
        let id = model.id
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CreditItems")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)

        do {
            let result = try context.fetch(fetchRequest)
            if let entity = result.first as? CreditItems {
                // Update the properties of the entity
                entity.payment_date = model.paymentDate
                entity.remaining_debt = model.remainingDebt
                entity.paid_count = Int32(model.paidCount)
                // Save the managed object context
                try context.save()
            }
        } catch {
            print("Error fetching data: \(error)")
        }






    }
}
