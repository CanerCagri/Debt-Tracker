//
//  CurrencyTableViewCell.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 13.02.2023.
//

import UIKit

class CurrencyTableViewCell: UITableViewCell {

    static let identifier = "CurrencyTableViewCell"
    
    var currencyLabel = DTTitleLabel(textAlignment: .center, fontSize: 15)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        applyConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func applyConstraints() {
        addSubview(currencyLabel)
        
        currencyLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        currencyLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        currencyLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5).isActive = true
        currencyLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5).isActive = true
    }
}
