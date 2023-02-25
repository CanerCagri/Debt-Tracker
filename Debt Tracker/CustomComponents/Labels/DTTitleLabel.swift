//
//  DTTitleLabel.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 27.01.2023.
//

import UIKit

class DTTitleLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(textAlignment: NSTextAlignment, fontSize: CGFloat, text: String? = "") {
        super.init(frame: .zero)
        self.textAlignment = textAlignment
        self.font = UIFont(name: "GillSans-SemiBold", size: fontSize)
        self.text = text
        self.textColor = .label
        configure()
    }
    
    init(textAlignment: NSTextAlignment, fontSize: CGFloat, textColor: UIColor, text: String? = "") {
        super.init(frame: .zero)
        self.textAlignment = textAlignment
        self.font = UIFont(name: "GillSans-SemiBold", size: fontSize)
        self.text = text
        self.textColor = textColor
        configure()
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        adjustsFontSizeToFitWidth = true
        minimumScaleFactor = 0.72
        lineBreakMode = .byTruncatingTail
    }
}
