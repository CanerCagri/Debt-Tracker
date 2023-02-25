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
    }
    
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        title = "Credits"
        view.addSubviews(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        contentView.heightAnchor.constraint(equalToConstant: 600).isActive = true
        contentView.addSubview(creditsTableView)
        contentView.backgroundColor = .systemGray5
    }
    
    private func configureTableView() {
        creditsTableView.frame = view.bounds
        
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
                
                if self!.credits.isEmpty {
                    self?.emptyState = DTEmptyStateView(message: "Currently don't have a Credit")
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
        
        cell.set(credit: credits[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedCredit = credits[indexPath.row]
        let detailVc = CreditsDetailViewController()
        detailVc.documentId = documentIds[indexPath.row]
        detailVc.creditModel = selectedCredit
        navigationController?.pushViewController(detailVc, animated: true)
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
