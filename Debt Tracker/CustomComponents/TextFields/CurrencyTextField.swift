//
//  CurrencyTextField.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 18.02.2023.
//

import UIKit

class CurrencyTextField: UITextField {
    
    var passTextFieldText: ((String, Double?) -> Void)?
    
    var currency: Currency? {
        didSet {
            guard let currency = currency else { return }
            numberFormatter.currencyCode = currency.code
            numberFormatter.locale = Locale(identifier: currency.locale)
        }
    }
    
    //Used to send clean double value back
    private var amountAsDouble: Double?
    
    var startingValue: Double? {
        didSet {
            let nsNumber = NSNumber(value: startingValue ?? 0.0)
            self.text = numberFormatter.string(from: nsNumber)
        }
    }
    
    private lazy var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        //locale and currencyCode set in currency property observer
        return formatter
    }()
    
    private var roundingPlaces: Int {
        return numberFormatter.maximumFractionDigits
    }
    
    private var isSymbolOnRight = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //If using in SBs
        setup()
    }
    
    init(size: CGFloat, placeHolder: String) {
        super.init(frame: .zero)
        font = UIFont(name: "GillSans-SemiBold", size: size)
        placeholder = placeHolder
        setup()
    }
    
    private func setup() {
        textAlignment = .center
        keyboardType = .numberPad
        contentScaleFactor = 0.5
        layer.borderWidth = 2
        layer.borderColor = UIColor.systemGray4.cgColor
        layer.cornerRadius = 10
        textColor = .label
        tintColor = .label
        delegate = self
        translatesAutoresizingMaskIntoConstraints = false
        
        backgroundColor = .systemGray6
        autocorrectionType = .no
        returnKeyType = .go
        clearButtonMode = .whileEditing
        self.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    //AFTER entered string is registered in the textField
    @objc private func textFieldDidChange() {
        updateTextField()
    }
    
    //Placed in separate method so when the user selects an account with a different currency, it will immediately be reflected
    private func updateTextField() {
        var cleanedAmount = ""
        
        for character in self.text ?? "" {
            if character.isNumber {
                cleanedAmount.append(character)
            }
        }
        
        if isSymbolOnRight {
            cleanedAmount = String(cleanedAmount.dropLast())
        }
        
        //Format the number based on number of decimal digits
        if self.roundingPlaces > 0 {
            //ie. USD
            let amount = Double(cleanedAmount) ?? 0.0
            amountAsDouble = (amount / 100.0)
            let amountAsString = numberFormatter.string(from: NSNumber(value: amountAsDouble ?? 0.0)) ?? ""
            
            self.text = amountAsString
        } else {
            //ie. JPY
            let amountAsNumber = Double(cleanedAmount) ?? 0.0
            amountAsDouble = amountAsNumber
            self.text = numberFormatter.string(from: NSNumber(value: amountAsNumber)) ?? ""
        }
        
        passTextFieldText?(self.text!, amountAsDouble)
    }
    
    //Prevents the user from moving the cursor in the textField
    override func closestPosition(to point: CGPoint) -> UITextPosition? {
        let beginning = self.beginningOfDocument
        let end = self.position(from: beginning, offset: self.text?.count ?? 0)
        return end
    }
}

extension CurrencyTextField: UITextFieldDelegate {
    
    //BEFORE entered string is registered in the textField
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let lastCharacterInTextField = (textField.text ?? "").last
        
        //Note - not the most straight forward implementation but this subclass supports both right and left currencies
        if string == "" && lastCharacterInTextField!.isNumber == false {
            //For hitting backspace and currency is on the right side
            isSymbolOnRight = true
        } else {
            isSymbolOnRight = false
        }
        
        return true
    }
}
