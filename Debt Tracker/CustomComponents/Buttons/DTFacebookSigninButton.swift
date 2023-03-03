//
//  DTFacebookSigninButton.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 24.02.2023.
//

import UIKit

class DTFacebookSigninButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        configure()
    }
    
    init(iconCentered: Bool) {
        super.init(frame: .zero)
        
        if iconCentered == true {
            configure()
        } else {
            configureWithIconCentered()
        }
    }
    
    private func configure() {
        configuration = .filled()
        translatesAutoresizingMaskIntoConstraints = false
        
        configuration?.baseBackgroundColor = K.Colors.facebookBackgroundColor
        configuration?.baseForegroundColor = .white
        
        var container = AttributeContainer()
        container.font = UIFont.boldSystemFont(ofSize: 14)
        configuration?.attributedTitle = AttributedString("Sign in with Facebook", attributes: container)
        
        configuration?.image = UIImage(named: "FacebookButton")
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
    
    private func configureWithIconCentered() {
        configuration = .filled()
        translatesAutoresizingMaskIntoConstraints = false
        
        configuration?.baseBackgroundColor = K.Colors.facebookBackgroundColor
        configuration?.baseForegroundColor = .white
        
        var container = AttributeContainer()
        container.font = UIFont.boldSystemFont(ofSize: 14)
        configuration?.attributedTitle = AttributedString("Continue with Facebook", attributes: container)
        
        configuration?.image = UIImage(named: "FacebookButton")
        configuration?.imagePadding = 5
        configuration?.imagePlacement = .leading
        
        if let label = subviews.first(where: { $0 is UILabel }) {
            label.translatesAutoresizingMaskIntoConstraints = false
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 13).isActive = true
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            
            if let imageView = subviews.first(where: { $0 is UIImageView }) {
                imageView.translatesAutoresizingMaskIntoConstraints = false
                imageView.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: -5).isActive = true
                imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
                imageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
                imageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
            }
        }
    }
}
