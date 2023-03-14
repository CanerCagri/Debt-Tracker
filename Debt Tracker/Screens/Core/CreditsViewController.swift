//
//  ViewController.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 27.01.2023.
//

import UIKit
import Firebase

class CreditsViewController: UIViewController {
    
    let db = Firestore.firestore()
    var documentIds: [String] = []
    let creditsTableView = UITableView()
    let contentView = UIView()
    var emptyState: DTEmptyStateView?
    private var credits: [CreditDetailModel] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        configureTableView()
        fetchFromFirebase()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.hidesBackButton = true
    }
    
    private func configureViewController() {
        if traitCollection.userInterfaceStyle == .dark {
            view.backgroundColor = UIColor(red: 28/255, green: 30/255, blue: 33/255, alpha: 1.0)
            creditsTableView.backgroundColor = UIColor(red: 28/255, green: 30/255, blue: 33/255, alpha: 1.0)
        } else {
            view.backgroundColor = UIColor.secondarySystemBackground
            creditsTableView.backgroundColor = .secondarySystemBackground
        }
        title = "Credits"
        view.addSubview(creditsTableView)
        creditsTableView.translatesAutoresizingMaskIntoConstraints = false
        creditsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        creditsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        creditsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        creditsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    private func configureTableView() {
        creditsTableView.delegate = self
        creditsTableView.dataSource = self
        creditsTableView.rowHeight = 200
        creditsTableView.register(CreditsTableViewCell.self, forCellReuseIdentifier:CreditsTableViewCell.identifier)
    }
    
    private func fetchFromFirebase() {
        FirestoreManager.shared.fetchCredit { [weak self] result in
            switch result {
            case .success(let success):
                self?.credits = success.creditDetails
                self?.documentIds = success.stringArray
                
                guard let credits = self?.credits.isEmpty else { return }
                if credits {
                    self?.emptyState = DTEmptyStateView(message: "Currently don't have Credit\nAdd from Create Credit Page.")
                    self?.emptyState?.frame = (self?.view.bounds)!
                    self?.view.addSubview((self?.emptyState!)!)
                    
                } else {
                    self?.emptyState?.removeFromSuperview()
                }
                
                DispatchQueue.main.async {
                    self?.creditsTableView.reloadData()
                }
            case .failure(let failure):
                self?.presentAlert(title: "Warning", message: failure.localizedDescription, buttonTitle: "OK")
            }
        }
    }
}

extension CreditsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return credits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CreditsTableViewCell.identifier) as! CreditsTableViewCell
        cell.applyShadow(cornerRadius: 8)
        cell.set(credit: credits[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedCredit = credits[indexPath.row]
        let detailVc = CreditsDetailViewController()
        detailVc.documentId = documentIds[indexPath.row]
        detailVc.creditModel = selectedCredit
        let navigationController = UINavigationController(rootViewController: detailVc)
        present(navigationController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        switch editingStyle {
        case .delete:
            FirestoreManager.shared.deleteCredit(documentId: documentIds[indexPath.row])
            documentIds.remove(at: indexPath.row)
            credits.remove(at: indexPath.row)
        default:
            break
        }
    }
}
