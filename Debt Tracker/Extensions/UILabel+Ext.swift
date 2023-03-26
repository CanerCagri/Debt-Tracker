//
//  UILabel+Ext.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 26.03.2023.
//

import UIKit

extension UILabel {
    func addIcon(icon: UIImage, text: String, iconSize: CGSize, xOffset: CGFloat, yOffset: CGFloat) {
           let attachment = NSTextAttachment()
           attachment.image = icon
           attachment.bounds = CGRect(origin: CGPoint(x: xOffset, y: yOffset), size: iconSize)

           let attachmentString = NSAttributedString(attachment: attachment)
           let mutableAttributedString = NSMutableAttributedString(string: "")
           mutableAttributedString.append(attachmentString)

           let textString = NSMutableAttributedString(string: " \(text)")
           mutableAttributedString.append(textString)

           self.attributedText = mutableAttributedString
       }
}
