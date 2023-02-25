//
//  Currency.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 18.02.2023.
//

import UIKit

struct Currency {
    let locale: String
    let amount: Double
    
    var code: String? {
        return formatter.currencyCode ?? "N/A"
    }
    
    var symbol: String? {
        return formatter.currencySymbol  ?? "N/A"
    }
    
    var format: String {
        return formatter.string(from: NSNumber(value: self.amount))!
    }
    
    var formatter: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: self.locale)
        numberFormatter.numberStyle = .currency
        
        return numberFormatter
    }
    
    func retrieveDetailedInformation() -> (String) {
        
        return "\(code ?? "N/A")  -  \(symbol ?? "N/A")"
    }
    
    func retriviedCurrencySymbol() -> (String) {
        return symbol ?? "N/A"
    }
    
    func retriviedLocale() -> (String) {
        return locale
    }
    
    
    //MARK: Use when saving to a database which only requires numeric values
    static func formatCurrencyStringAsDouble(with localeString: String, for stringAmount: String, viewController : UIViewController, documentId: String, presentVc: UIViewController? = MainTabBarViewController()) -> Double {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: localeString)
        numberFormatter.numberStyle = .currency
        
        if let number = numberFormatter.number(from: stringAmount)?.doubleValue {
            return number
        } else {
            let alert = UIAlertController(title: "Warning", message: "Oops. Selected Currency is not supported.\n Please try with another Currency.", preferredStyle: .alert)
            
            let deleteCreditAction = UIAlertAction(title: "Delete Credit", style: .destructive) { (action) in
                FirestoreManager.shared.deleteCredit(documentId: documentId)
                viewController.navigationController?.popToRootViewController(animated: true)
            }
            
            alert.addAction(deleteCreditAction)
            
            viewController.present(alert, animated: true, completion: nil)
            return 0.0
        }
    }
    
    //MARK: Same function with formatCurrencyStringAsDouble, but without Locale
    static func convertToDouble(with localeString: String, for stringAmount: String) -> Double{
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: localeString)
        numberFormatter.numberStyle = .currency
        
        if let number = numberFormatter.number(from: stringAmount)?.doubleValue {
            return number
        } else {
            
            return 0.0
        }
    }
    
    //MARK: Currency Input Formatting - called when the user enters an amount in the
    static func currencyInputFormatting(with localeString: String, for amount: String) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: localeString)
        numberFormatter.numberStyle = .currency
        
        let numberOfDecimalPlaces = numberFormatter.maximumFractionDigits
        
        //Clean the inputed string
        var cleanedAmount = ""
        
        for character in amount {
            if character.isNumber {
                cleanedAmount.append(character)
            }
        }
        
        //Format the number based on number of decimal digits
        if numberOfDecimalPlaces > 0 {
            //ie. USD
            let amountAsDouble = Double(cleanedAmount) ?? 0.0
            
            return numberFormatter.string(from: amountAsDouble / 100.0 as NSNumber) ?? ""
        } else {
            //ie. JPY
            let amountAsNumber = Double(cleanedAmount) as NSNumber?
            return numberFormatter.string(from: amountAsNumber ?? 0) ?? ""
        }
    }
}

struct Currencies {
    static func retrieveAllCurrencies() -> [Currency] {
        let allowedCurrencyCodes = ["USD", "EUR", "GBP", "JPY", "AUD", "CAD", "TRY"]
        var currencies = [Currency]()
        for locale in Locale.availableIdentifiers {
            let loopLocale = Locale(identifier: locale)
            if let currencyCode = loopLocale.currencyCode, allowedCurrencyCodes.contains(currencyCode) {
                let currency = Currency(locale: loopLocale.identifier, amount: 1000.00)
                
                if let firstChar = currency.format.first, !firstChar.isNumber {
                    if !currency.format.contains(" ") {
                        currencies.append(currency)
                    }
                    
                }
            }
        }
        
        return currencies.sorted(by: { $0.locale < $1.locale })
    }
}
