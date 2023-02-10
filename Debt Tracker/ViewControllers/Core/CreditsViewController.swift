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
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("saveTapped"), object: nil, queue: nil) { [weak self] _ in
            self?.fetchFromFirebase()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("paymentUpdated"), object: nil, queue: nil) { [weak self] _ in
            self?.fetchFromFirebase()
        }
    }
    
    private func configureTableView() {
        creditsTableView.frame = view.bounds

        creditsTableView.delegate = self
        creditsTableView.dataSource = self
        creditsTableView.rowHeight = 200
        creditsTableView.register(CreditsTableViewCell.self, forCellReuseIdentifier:CreditsTableViewCell.identifier)
    }
    
    private func fetchFromFirebase() {
        db.collection("credits").addSnapshotListener { [weak self] querySnapShot, error in
            
            self?.credits = []
            
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let querySnapShotDocuments = querySnapShot?.documents {
                    for doc in querySnapShotDocuments {
                        let data = doc.data()
                       
                        if let name = data["name"] as? String,
                           let detail = data["detail"] as? String,
                           let entryDebt = data["entryDebt"] as? Int,
                           let installmentCount = data["installmentCount"] as? Int,
                           let paidCount = data["paidCount"] as? Int,
                           let monthlyInstallment = data["monthlyInstallment"] as? Double,
                           let firstInstallmentDate = data["firstInstallmentDate"] as? String,
                           let currentInstallmentDate = data["currentInstallmentDate"] as? String,
                           let totalDebt = data["totalDebt"] as? Double,
                           let interestRate = data["interestRate"] as? Double,
                           let remainingDebt = data["remainingDebt"] as? Double,
                           let paidDebt = data["paidDebt"] as? Double,
                           let email = data["email"] as? String {
                            
                            if email == Auth.auth().currentUser?.email {
                                
                                let creditModel = CreditDetailModel(name: name, detail: detail, entryDebt: entryDebt, installmentCount: installmentCount, paidCount: paidCount, monthlyInstallment: monthlyInstallment, firstInstallmentDate: firstInstallmentDate, currentInstallmentDate: currentInstallmentDate, totalDebt: totalDebt, interestRate: interestRate, remainingDebt: remainingDebt, paidDebt: paidDebt, email: email)
                                self?.credits.append(creditModel)
                                self?.documentIds.append(doc.documentID)
                            }
                        }
                    }
                }
            }
            
            if self!.credits.isEmpty {
                self?.emptyState = DTEmptyStateView(message: "Currently don't have a Credit")
                self?.emptyState?.frame = (self?.view.bounds)!
                self?.view.addSubview((self?.emptyState!)!)
                
                DispatchQueue.main.async {
                    self?.creditsTableView.reloadData()
                }
            } else {
                self?.emptyState?.removeFromSuperview()
                
                DispatchQueue.main.async {
                    self?.creditsTableView.reloadData()
                }
            }
        }
    }
    
    func deleteDocument(documentId: String) {
        let documentRef = db.collection("credits").document(documentId)

        documentRef.delete { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
               print("Succesfully removed")
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
            deleteDocument(documentId: documentIds[indexPath.row])
            documentIds.remove(at: indexPath.row)
            credits.remove(at: indexPath.row)
        default:
            break
        }
    }
}
