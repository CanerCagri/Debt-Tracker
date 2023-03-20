//
//  CreditsAddDetailMainVc.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 1.02.2023.
//

import UIKit
import Firebase

class CreditsMainViewController: UIViewController {
    
    let db = Firestore.firestore()
    var documentIds: [String] = []
    private var banks: [BankDetails] = []
    var emptyState: DTEmptyStateView?
    
    var creditsCollectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource <Section, BankDetails>!
    var isRightBarButtonTapped = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        configureViewController()
        configureDataSource()
        fetchFromFirestore()
    }
    
    private func configureViewController() {
        title = "Create Credit"
        view.setBackgroundColor()
        creditsCollectionView.backgroundColor = .systemGray5
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: SFSymbols.logoutSymbol), style: .done, target: self, action: #selector(logoutButtonTapped)),
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(rightBarButtonTapped))
        ]
        
        NotificationCenter.default.addObserver(forName: .createBankVcClosed, object: nil, queue: nil) { [weak self] (notification) in
            self?.isRightBarButtonTapped = false
        }
        self.tabBarController?.delegate = self
    }
    
    func configureCollectionView() {
        creditsCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UIHelper.createThreeColumnFlowLayout(view: view))
        view.addSubview(creditsCollectionView)
        creditsCollectionView.delegate = self
        creditsCollectionView.backgroundColor = .systemBackground
        creditsCollectionView.register(CreditsCollectionViewCell.self, forCellWithReuseIdentifier: K.creditsCollectionViewCellIdentifier)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        creditsCollectionView.addGestureRecognizer(longPressGesture)
    }
    
    private func fetchFromFirestore() {
        FirestoreManager.shared.fetchBanks { [weak self] result in
            switch result {
            case .success(let success):
                self?.banks = success.bankDetails
                self?.documentIds = success.stringArray
                
                if self!.banks.isEmpty {
                    self?.emptyState = DTEmptyStateView(message: "Currently don't have Bank\nAdd from (+)")
                    self?.emptyState?.frame = (self?.view.bounds)!
                    self?.view.addSubview((self?.emptyState!)!)
                    
                } else {
                    self?.emptyState?.removeFromSuperview()
                }
                DispatchQueue.main.async {
                    self?.creditsCollectionView.reloadData()
                }
                
                self?.updateData(banks: self!.banks)
                
            case .failure(let failure):
                print("Önemsiz bir uyarı: \(failure.localizedDescription)")
            }
        }
    }
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            guard let selectedIndexPath = creditsCollectionView.indexPathForItem(at: gesture.location(in: creditsCollectionView)) else { break }
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                self?.showLoading()
                FirestoreManager.shared.deleteBank(documentId: (self?.documentIds[selectedIndexPath.row])!)
                self?.banks.remove(at: selectedIndexPath.row)
                self?.documentIds.remove(at: selectedIndexPath.row)
                self?.dismissLoading()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true)
        default:
            break
        }
    }
    
    @objc func rightBarButtonTapped() {
        
        if !isRightBarButtonTapped {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2 ) { [weak self] in
                
                let popupVc = CreateBankPopupVc()
                popupVc.modalTransitionStyle = .crossDissolve
                popupVc.modalPresentationStyle = .overFullScreen
                self?.present(popupVc, animated: true)
            }
            isRightBarButtonTapped = true
        }
    }
    
    @objc func logoutButtonTapped() {
        do {
            try Auth.auth().signOut()
            FirestoreManager.shared.stopFetchingCredit()
            NotificationCenter.default.post(name: .signOutButtonTapped, object: nil)
            
        } catch let signOutError as NSError {
            print("Error when signing out: %@", signOutError)
        }
    }
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, BankDetails>(collectionView: creditsCollectionView, cellProvider: { collectionView, indexPath, banks in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.creditsCollectionViewCellIdentifier, for: indexPath) as! CreditsCollectionViewCell
            cell.set(banks: banks)
            return cell
        })
    }
    
    func updateData(banks: [BankDetails]) {
        var snapShot = NSDiffableDataSourceSnapshot<Section, BankDetails>()
        snapShot.appendSections([.main])
        snapShot.appendItems(banks)
        
        dataSource.apply(snapShot, animatingDifferences: true)
    }
}

extension CreditsMainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        view.backgroundColor = .gray
        
        let addCreditVc = AddCreditViewController()
        addCreditVc.selectedCredit = banks[indexPath.row]
        navigationController?.pushViewController(addCreditVc, animated: true)
    }
}

extension CreditsMainViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let navigationController = viewController as? UINavigationController {
            navigationController.popToRootViewController(animated: false)
        }
    }
}
