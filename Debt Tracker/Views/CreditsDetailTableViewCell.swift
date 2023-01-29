//
//  CreditsDetailTableViewCell.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 29.01.2023.
//

import UIKit

class CreditsDetailTableViewCell: UITableViewCell {

    static let identifier = "CreditsDetailTableViewCell"
    
    
    var nameLabel = DTTitleLabel(textAlignment: .left, fontSize: 14)
    var priceLabel = DTTitleLabel(textAlignment: .center, fontSize: 14)
    var dateLabel = DTTitleLabel(textAlignment: .left, fontSize: 14)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        applyConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    func applyConstraints() {
        addSubviews(nameLabel, priceLabel, dateLabel)
        
        nameLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        
        priceLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        priceLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        dateLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        dateLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
    }
}
