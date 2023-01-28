//
//  ViewController.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 27.01.2023.
//

import UIKit

class CreditsViewController: UIViewController {
    
    let creditsTableView = UITableView()
    let contentView = UIView()
    
    var credits: [CreditModel] = [
//        CreditModel(name: "Enpara - Nakit Avans", entryDebt: 2000000, paidCount: 2, monthlyDebt: 21872, paymentDate: "01.12.2023", currendDebt: 12000),
//        CreditModel(name: "test", entryDebt: 10000000, paidCount: 4, monthlyDebt: 250000, paymentDate: "02.07.2021", currendDebt: 10000000),
//        CreditModel(name: "test2", entryDebt: 10000000, paidCount: 7, monthlyDebt: 500000, paymentDate: "02.07.2021", currendDebt: 10000000),
//        CreditModel(name: "test3", entryDebt: 10000000, paidCount: 11, monthlyDebt: 2000, paymentDate: "02.07.2021", currendDebt: 10000000),
//        CreditModel(name: "test4", entryDebt: 10000000, paidCount: 0, monthlyDebt: 250000, paymentDate: "02.07.2021", currendDebt: 10000000),
//        CreditModel(name: "test5", entryDebt: 10000000, paidCount: 1, monthlyDebt: 250000, paymentDate: "02.07.2021", currendDebt: 10000000),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        configureTableView()
    }
    
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        title = "Credits"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(rightBarButtonTapped))
    }
    
    private func configureTableView() {
        view.addSubviews(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        contentView.heightAnchor.constraint(equalToConstant: 600).isActive = true
        contentView.addSubview(creditsTableView)
        contentView.backgroundColor = .systemGray5
        
        creditsTableView.frame = view.bounds
//        creditsTableView.translatesAutoresizingMaskIntoConstraints = false
//        creditsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
//        creditsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//        creditsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
//        creditsTableView.heightAnchor.constraint(equalToConstant: scrol).isActive = true
        creditsTableView.delegate = self
        creditsTableView.dataSource = self
        creditsTableView.rowHeight = 200
        creditsTableView.register(CreditsTableViewCell.self, forCellReuseIdentifier:CreditsTableViewCell.identifier)
    }
    
    @objc func rightBarButtonTapped() {
        let detailVc = CreditsAddViewController()
        let navigationController = UINavigationController(rootViewController: detailVc)
        present(navigationController, animated: true)
    }
}

extension CreditsViewController: UITableViewDelegate, UITableViewDataSource {
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return credits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CreditsTableViewCell.identifier) as! CreditsTableViewCell
        
        cell.set(credit: credits[indexPath.row])
        return cell
    }
}

