//
//  MainTabBarViewController.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 1.02.2023.
//

import UIKit

class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vc1 = UINavigationController(rootViewController: CreditsMainViewController())
        let vc2 = UINavigationController(rootViewController: CreditsViewController())
        
        vc1.tabBarItem.image = UIImage(systemName: SFSymbols.createCreditTabSymbol)
        vc2.tabBarItem.image = UIImage(systemName: SFSymbols.creditsTabSymbol)
        
        vc1.title = "Create Credit"
        vc2.title = "Credits"
        
        tabBar.tintColor = .label
        tabBar.backgroundColor = .systemBackground
        
        setViewControllers([vc1, vc2], animated: true)
    }
}
