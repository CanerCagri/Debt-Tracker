//
//  SplashScreenViewController.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 24.02.2023.
//

import UIKit

class SplashScreenViewController: UIViewController {
    
    private let welcomeLabel = DTTitleLabel(textAlignment: .center, fontSize: 32)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemPink
        welcomeLabel.textColor = .systemBackground
        welcomeLabel.text = "Debt Tracker"
        
        view.addSubview(welcomeLabel)
        NSLayoutConstraint.activate([
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            welcomeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            let loginViewController = LoginViewController()
            loginViewController.navigationItem.hidesBackButton = true
            self.navigationController?.pushViewController(loginViewController, animated: true)
        }
    }
}
