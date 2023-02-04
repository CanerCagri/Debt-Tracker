//
//  CreditsAddDetailMainVc.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 1.02.2023.
//

import UIKit

class CreditsAddDetailMainViewController: UIViewController {
    enum Section {
        case main
    }
    
    private var banks: [CreditDetails] = []
    var emptyState: DTEmptyStateView?
    
    var creditsCollectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource <Section, CreditDetails>!
    var isRightBarButtonTapped = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        configureCollectionView()
        configureDataSource()
        fetchFromCoredata()
        
    }
    
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        title = "Create Credit"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(leftBarButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(rightBarButtonTapped))
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("popupCreateCreditCancelTapped"), object: nil, queue: nil) { [weak self] (notification) in
            self?.isRightBarButtonTapped = false
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name("popupCreateCreditCreateTapped"), object: nil, queue: nil) { [weak self] (notification) in
            self?.isRightBarButtonTapped = false
            self?.fetchFromCoredata()
        }
    }
    
    func configureCollectionView() {
        creditsCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UIHelper.createThreeColumnFlowLayout(view: view))
        view.addSubview(creditsCollectionView)
        creditsCollectionView.delegate = self
        creditsCollectionView.backgroundColor = .systemBackground
        creditsCollectionView.register(CreditsCollectionViewCell.self, forCellWithReuseIdentifier: CreditsCollectionViewCell.identifier)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        creditsCollectionView.addGestureRecognizer(longPressGesture)
    }
    
    private func fetchFromCoredata() {
        PersistenceManager.shared.fetchBanks { [weak self] result in
            switch result {
            case .success(let success):
                if success.isEmpty {
                    self?.emptyState = DTEmptyStateView(message: "Currently don't have a Bank\nAdd from (+)")
                    self?.emptyState?.frame = (self?.view.bounds)!
                    self?.view.addSubview((self?.emptyState!)!)
                    
                } else {
                    self?.emptyState?.removeFromSuperview()
                    self?.banks = success
                    
                    DispatchQueue.main.async {
                        self?.creditsCollectionView.reloadData()
                    }
                }
                self?.updateData(banks: self!.banks)
            case .failure(_):
                self?.presentDefaultError()
            }
        }
    }
    
    func removeItem(at indexPath: IndexPath) {
        PersistenceManager.shared.deleteBankWith(model: banks[indexPath.item]) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(_):
                var snapShot = self.dataSource.snapshot()
                snapShot.deleteItems([snapShot.itemIdentifiers[indexPath.item]])
                self.dataSource.apply(snapShot, animatingDifferences: true)
            case .failure(_):
                self.presentDefaultError()
            }
        }
    }
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            guard let selectedIndexPath = creditsCollectionView.indexPathForItem(at: gesture.location(in: creditsCollectionView)) else { break }
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                self.removeItem(at: selectedIndexPath)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true)
        default:
            break
        }
    }
    
    @objc func leftBarButtonTapped() {
        if banks.isEmpty {
            presentAlert(title: "Warning", message: "Don't have Bank to be removed.", buttonTitle: "Ok")
            
        } else {
            let alertController = UIAlertController(title: "Deleting All Banks", message: nil, preferredStyle: .alert)
            
            let deleteButton = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                PersistenceManager.shared.deleteAllBanks()
                self?.banks.removeAll()
                self?.fetchFromCoredata()
            }
            
            let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
            
            alertController.addAction(deleteButton)
            alertController.addAction(cancelButton)
            present(alertController, animated: true)
        }
    }
    
    @objc func rightBarButtonTapped() {
        
        if !isRightBarButtonTapped {
            view.backgroundColor = .gray
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2 ) { [weak self] in
                let popupVc = CreateCreditPopupVc()
                
                self?.addChild(popupVc)
                self?.view.addSubview(popupVc.view)
                popupVc.didMove(toParent: self)
            }
            isRightBarButtonTapped = true
        }
        
    }
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, CreditDetails>(collectionView: creditsCollectionView, cellProvider: { collectionView, indexPath, banks in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CreditsCollectionViewCell.identifier, for: indexPath) as! CreditsCollectionViewCell
            cell.set(banks: banks)
            return cell
        })
    }
    
    func updateData(banks: [CreditDetails]) {
        var snapShot = NSDiffableDataSourceSnapshot<Section, CreditDetails>()
        snapShot.appendSections([.main])
        snapShot.appendItems(banks)
        
        dataSource.apply(snapShot, animatingDifferences: true)
    }
}

extension CreditsAddDetailMainViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: true)
        view.backgroundColor = .gray
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2 ) { [weak self] in
            let popupVc = CreditsPopupVc()
            popupVc.selectedCredit = self?.banks[indexPath.row]
            self?.addChild(popupVc)
            self?.view.addSubview(popupVc.view)
            popupVc.didMove(toParent: self)
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, commit editingStyle: UITableViewCell.EditingStyle, forItemAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Remove the item from your data source
            
            
            // Delete the item from the collection view
            collectionView.deleteItems(at: [indexPath])
        }
    }
    
}


