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
    let creditsTableView = UITableView()
    let contentView = UIView()
    var emptyState: DTEmptyStateView?
    let viewModel = CreditsViewModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        configureTableView()
        viewModel.delegate = self
        viewModel.fetchCredits()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.hidesBackButton = true
    }
    
    private func configureViewController() {
        view.setBackgroundColor()
        creditsTableView.backgroundColor = .systemGray4
        
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
}

extension CreditsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CreditsTableViewCell.identifier) as! CreditsTableViewCell
        cell.applyShadow(cornerRadius: 8)
        cell.set(credit: viewModel.credits[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedCredit = viewModel.credits[indexPath.row]
        let detailVc = CreditsDetailViewController()
        detailVc.documentId = viewModel.documentIds[indexPath.row]
        detailVc.creditModel = selectedCredit
        let navigationController = UINavigationController(rootViewController: detailVc)
        present(navigationController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        switch editingStyle {
        case .delete:
            viewModel.removeCredits(documentId: viewModel.documentIds[indexPath.row])
            viewModel.documentIds.remove(at: indexPath.row)
            viewModel.credits.remove(at: indexPath.row)
            
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        let verticalPadding: CGFloat = 15
        
        let maskLayer = CALayer()
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.frame = CGRect(x: cell.bounds.origin.x, y: cell.bounds.origin.y, width: cell.bounds.width, height: cell.bounds.height).insetBy(dx: 0, dy: verticalPadding/2)
        cell.layer.mask = maskLayer
    }
}

extension CreditsViewController: CreditsViewModelDelegate {
    
    func handleViewModelOutput(_ result: Result<CreditData, Error>) {
    
        switch result {
        case .success(let success):
            viewModel.credits = success.creditDetails
            viewModel.documentIds = success.stringArray
            
            if viewModel.credits.isEmpty {
                emptyState = DTEmptyStateView(message: "Currently don't have Credit\nAdd from Create Credit Page.")
                emptyState?.frame = view.bounds
                view.addSubview(emptyState!)
                
            } else {
                emptyState?.removeFromSuperview()
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.creditsTableView.reloadData()
            }
            
        case .failure(let failure):
            presentAlert(title: "Warning", message: failure.localizedDescription, buttonTitle: "OK")
        }
    }
}
