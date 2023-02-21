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
    var entryDebt: String
    var installmentCount: Int
    var paidCount: Int
    var monthlyInstallment: String
    var firstInstallmentDate: String
    var currentInstallmentDate: String
    var totalDebt: String
    var interestRate: Double
    var remainingDebt: String
    var paidDebt: String
    var email: String
    var currency: String
}
