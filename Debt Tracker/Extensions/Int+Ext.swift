//
//  Int+Ext.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 28.01.2023.
//

import Foundation

extension Int {
    func ordinal() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter.string(for: self + 1) ?? ""
    }
}
