//
//  CreditModel.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 27.01.2023.
//

import Foundation

struct CreditModel {
    var id = UUID()
    var name: String
    var entryDebt: Int
    var paidCount: Int
    var monthlyDebt: Double
    var paymentDate: String
    var currentDebt: Int
    var remainingDebt: Double
}
