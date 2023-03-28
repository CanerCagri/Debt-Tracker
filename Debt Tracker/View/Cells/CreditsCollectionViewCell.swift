//
//  CreditsCollectionViewCell.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 1.02.2023.
//

import UIKit

class CreditsCollectionViewCell: UICollectionViewCell {
    
    var creditNameLabel = DTTitleLabel(textAlignment: .center, fontSize: 18)
    var creditDetailLabel = DTTitleLabel(textAlignment: .center, fontSize: 14)
    var creditButton = DTButton(title: "Create Credit", color: .systemRed, size: 12)
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(banks: BankDetails) {
       
        creditNameLabel.text = banks.name
        creditDetailLabel.text = banks.detail
    }
    
    private func configure() {
        creditNameLabel.numberOfLines = 2
        creditDetailLabel.numberOfLines = 2
        creditButton.isUserInteractionEnabled = false
        if traitCollection.userInterfaceStyle == .dark {
            backgroundColor = .systemGray6
            
        } else {
            backgroundColor = .systemGray
        }
        
        self.layer.cornerRadius = 14
        
        addSubviews(creditNameLabel, creditDetailLabel, creditButton)
        
        creditNameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        creditNameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
        creditNameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
        
        let creditDetailLabelTopConstant: CGFloat = DeviceTypes.isiPhoneSE || DeviceTypes.isiPhone8PlusZoomed || DeviceTypes.isiPhone8Standard || DeviceTypes.isiPhone8Zoomed || DeviceTypes.isiPhone8PlusStandard ? 15 : 25
       
        creditDetailLabel.topAnchor.constraint(equalTo: creditNameLabel.bottomAnchor, constant: creditDetailLabelTopConstant).isActive = true
        creditDetailLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5).isActive = true
        creditDetailLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5).isActive = true
        
        creditButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5).isActive = true
        creditButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5).isActive = true
        creditButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -15).isActive = true
        creditButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
}
