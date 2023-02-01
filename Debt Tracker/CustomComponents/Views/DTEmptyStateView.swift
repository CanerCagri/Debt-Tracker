//
//  DTEmptyStateView.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 29.01.2023.
//

import UIKit

class DTEmptyStateView: UIView {

    let messageLabel = DTTitleLabel(textAlignment: .center, fontSize: 20)
    let logoImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(message: String) {
        super.init(frame: .zero)
        messageLabel.text = message
        configure()
    }
    
    private func configure() {
        addSubviews(messageLabel, logoImageView)
        
        messageLabel.numberOfLines = 3
        messageLabel.textColor = .secondaryLabel
        
        logoImageView.image = UIImage(systemName: "plus.message.fill")
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
//        let labelCenterYConstant: CGFloat = DeviceTypes.isiPhoneSE || DeviceTypes.isiPhone8PlusZoomed ? -90 : -150
//        let logoImageViewBottomConstant: CGFloat = DeviceTypes.isiPhoneSE || DeviceTypes.isiPhone8PlusZoomed ? 80 : 40
        
        NSLayoutConstraint.activate([
            messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -150),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
            messageLabel.heightAnchor.constraint(equalToConstant: 200),
        
            logoImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 20),
            logoImageView.widthAnchor.constraint(equalToConstant: 300),
            logoImageView.heightAnchor.constraint(equalToConstant: 300),
            logoImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 110),
        ])
    }
}
