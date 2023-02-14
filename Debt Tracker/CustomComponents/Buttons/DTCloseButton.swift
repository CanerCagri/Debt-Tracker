//
//  DTCloseButton.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 13.02.2023.
//

import UIKit

class DTCloseButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        imageView?.translatesAutoresizingMaskIntoConstraints = false
        imageView?.heightAnchor.constraint(equalToConstant: 44).isActive = true
        imageView?.widthAnchor.constraint(equalToConstant: 44).isActive = true
    }
}
