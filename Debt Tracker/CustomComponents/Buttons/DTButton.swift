//
//  DTButton.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 28.01.2023.
//

import UIKit

class DTButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(title: String, color: UIColor, systemImageName: String, size: CGFloat) {
        super.init(frame: .zero)
        configure()
        set(color: color, title: title, systemImageName: systemImageName, size: size)
    }
    
    init(title: String, color: UIColor, size: CGFloat? = 15) {
        super.init(frame: .zero)
        configure()
        configuration?.baseBackgroundColor = color
        configuration?.baseForegroundColor = .white
    
        var container = AttributeContainer()
        container.font = UIFont(name: "GillSans-SemiBold", size: size!)
        configuration?.attributedTitle = AttributedString(title, attributes: container)
        
    }
    
    private func configure() {
        configuration = .filled()
        configuration?.cornerStyle = .capsule
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func set(color: UIColor, title: String, systemImageName: String, size: CGFloat) {
        configuration?.baseBackgroundColor = color
        configuration?.baseForegroundColor = .white
        
        var container = AttributeContainer()
        container.font = UIFont(name: "GillSans-SemiBold", size: size)
        configuration?.attributedTitle = AttributedString(title, attributes: container)
        
        configuration?.image = UIImage(systemName: systemImageName)
        configuration?.imagePadding = 5
        configuration?.imagePlacement = .leading
    }
}
