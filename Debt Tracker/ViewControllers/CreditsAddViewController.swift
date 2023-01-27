//
//  CreditsAddViewController.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 27.01.2023.
//

import UIKit

class CreditsAddViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViewController()
    }
    
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissVC))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    @objc func dismissVC() {
        dismiss(animated: true)
    }

}
