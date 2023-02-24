//
//  UIHelper.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 1.02.2023.
//

import UIKit

enum UIHelper {
    
    static func createThreeColumnFlowLayout(view: UIView) -> UICollectionViewFlowLayout {
        let width = view.bounds.width
        let padding: CGFloat = 12
        let minimumItemSpace: CGFloat = 10
        let availableWidth = width - (padding * 2) - (minimumItemSpace * 2)
        let itemWidth = availableWidth / 3
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        flowLayout.itemSize = CGSize(width: itemWidth, height: itemWidth + 40)
     
        return flowLayout
    }
}

enum Section {
    case main
}


extension Notification.Name {
    static let signOutButton = Notification.Name("signOutButton")
}

