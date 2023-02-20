//
//  String+Ext.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 18.02.2023.
//

import UIKit

extension String {
    func isLastCharANumber() -> Bool {
        let lastChar = self.last!
        
        if lastChar.isNumber {
            return true
        } else {
            return false
        }
    }
}
