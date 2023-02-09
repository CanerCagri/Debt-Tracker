//
//  DTTextField.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 28.01.2023.
//

import UIKit

class DTTextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure(textSize: 12)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(placeholder: String, placeHolderSize: CGFloat, cornerRadius: CGFloat? = 10) {
        super.init(frame: .zero)
        attributedPlaceholder = NSAttributedString(string: placeholder, attributes:[NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font :UIFont(name: "Times New Roman", size: 12)!])
        layer.cornerRadius = cornerRadius!
        configure(textSize: placeHolderSize)
    }
    
    private func configure(textSize: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        
        layer.borderWidth = 2
        layer.borderColor = UIColor.systemGray4.cgColor
        textColor = .label
        tintColor = .label
        textAlignment = .center
        font = UIFont(name: "GillSans-SemiBold", size: textSize)!
        adjustsFontSizeToFitWidth = true
        minimumFontSize = 12
        
        backgroundColor = .systemGray6
        autocorrectionType = .no
        returnKeyType = .go
        clearButtonMode = .whileEditing
    }
}

