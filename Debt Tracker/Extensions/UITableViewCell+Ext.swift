//
//  UITableViewCell+Ext.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 18.02.2023.
//

import UIKit

extension UITableViewCell {
    class var identifier: String {
        return String(describing: self)
    }
}
