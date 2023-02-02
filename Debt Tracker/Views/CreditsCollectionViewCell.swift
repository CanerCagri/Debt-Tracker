//
//  CreditsCollectionViewCell.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 1.02.2023.
//

import UIKit

class CreditsCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "CreditsCollectionViewCell"
    
    var creditNameLabel = DTTitleLabel(textAlignment: .center, fontSize: 15)
    var creditDetailLabel = DTTitleLabel(textAlignment: .center, fontSize: 13)
    var creditButton = DTButton(title: "Apply", color: .systemRed)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(credit: CreditDetailsModel) {
       
        creditNameLabel.text = credit.name
        creditDetailLabel.text = credit.detail
    }
    
    private func configure() {
        creditNameLabel.textColor = .systemRed
        creditDetailLabel.numberOfLines = 0
        creditButton.isUserInteractionEnabled = false
        self.backgroundColor = .systemGray3
        self.layer.cornerRadius = 14
        
        addSubviews(creditNameLabel, creditDetailLabel, creditButton)
        
        creditNameLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        creditNameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        
        creditDetailLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        creditDetailLabel.topAnchor.constraint(equalTo: creditNameLabel.bottomAnchor, constant: 25).isActive = true
        
        creditButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5).isActive = true
        creditButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5).isActive = true
        creditButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -15).isActive = true
        creditButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
}
