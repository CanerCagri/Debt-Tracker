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
        let item = CreditItem(context: context)
        
        item.id = UUID()
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
}
