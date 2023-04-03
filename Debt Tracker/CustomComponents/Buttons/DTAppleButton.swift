//
//  DTAppleButton.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 31.03.2023.
//

import UIKit

class DTAppleButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if traitCollection.userInterfaceStyle == .dark {
            configureDark()
        } else {
            configureLight()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(iconCentered: Bool) {
        super.init(frame: .zero)
        
        if traitCollection.userInterfaceStyle == .dark {
            configureDark()
        } else {
            configureLight()
        }
    }
    
    private func configureDark() {
        configuration = .filled()
        translatesAutoresizingMaskIntoConstraints = false
        
        configuration?.baseBackgroundColor = .label
        configuration?.baseForegroundColor = .systemBackground
        
        var container = AttributeContainer()
        container.font = UIFont.boldSystemFont(ofSize: 14)
        configuration?.attributedTitle = AttributedString("Sign in with Apple", attributes: container)
        
        configuration?.image = UIImage(named: ImageName.darkAppleButton)
        
        configuration?.imagePadding = 5
        configuration?.imagePlacement = .leading
        
        if let imageView = subviews.first(where: { $0 is UIImageView }) {
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
            imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        }
        
        if let label = subviews.first(where: { $0 is UILabel }) {
            label.translatesAutoresizingMaskIntoConstraints = false
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 52).isActive = true
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        }
    }
    
    private func configureLight() {
        configuration = .filled()
        translatesAutoresizingMaskIntoConstraints = false
        
        configuration?.baseBackgroundColor = .label
        configuration?.baseForegroundColor = .systemBackground
        
        var container = AttributeContainer()
        container.font = UIFont.boldSystemFont(ofSize: 14)
        configuration?.attributedTitle = AttributedString("Sign in with Apple", attributes: container)
        
        configuration?.image = UIImage(named: ImageName.lightAppleButton)
        
        configuration?.imagePadding = 5
        configuration?.imagePlacement = .leading
        
        if let imageView = subviews.first(where: { $0 is UIImageView }) {
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 13).isActive = true
            imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        }
        
        if let label = subviews.first(where: { $0 is UILabel }) {
            label.translatesAutoresizingMaskIntoConstraints = false
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 52).isActive = true
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        }
    }
}

