//
//  CreditModel.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 27.01.2023.
//

import Foundation

struct CreditModel: Codable, Hashable {
    var id: String
    var name: String
    var entryDebt: Int
    var paidCount: Int
    var monthlyDebt: Double
    var paymentDate: String
    var currentDebt: Int
    var remainingDebt: Double
    var paidDebt: Double
}
