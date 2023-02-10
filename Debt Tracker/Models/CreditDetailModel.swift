//
//  CreditDetailModel.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 2.02.2023.
//

import Foundation

struct CreditDetailModel: Codable, Hashable {
    var name: String
    var detail: String
    var entryDebt: Int
    var installmentCount: Int
    var paidCount: Int
    var monthlyInstallment: Double
    var firstInstallmentDate: String
    var currentInstallmentDate: String
    var totalDebt: Double
    var interestRate: Double
    var remainingDebt: Double
    var paidDebt: Double
    var email: String
}
