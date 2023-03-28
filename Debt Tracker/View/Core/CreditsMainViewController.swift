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
    var emptyState: DTEmptyStateView?
    var viewModel = CreditsMainViewModel()
    
    var creditsCollectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource <Section, BankDetails>!
    var isRightBarButtonTapped = false
    var leftBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        configureCollectionView()
        configureDataSource()
        viewModel.fetchBanks()
    }
    
    private func configureViewController() {
        title = "Create Credit"
        view.setBackgroundColor()
        viewModel.delegate = self
        
        leftBarButton = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .done, target: self, action: #selector(settingsButtonTapped))
        navigationItem.leftBarButtonItem = leftBarButton
                                                           
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(rightBarButtonTapped))
        
        NotificationCenter.default.addObserver(forName: .createBankVcClosed, object: nil, queue: nil) { [weak self] (notification) in
            self?.isRightBarButtonTapped = false
        }
        self.tabBarController?.delegate = self
    }
    
    func configureCollectionView() {
        creditsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UIHelper.createThreeColumnFlowLayout(view: view))
        view.addSubview(creditsCollectionView)
        creditsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        creditsCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        creditsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        creditsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        creditsCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        creditsCollectionView.delegate = self
        creditsCollectionView.backgroundColor = .systemGray4
        creditsCollectionView.register(CreditsCollectionViewCell.self, forCellWithReuseIdentifier: K.creditsCollectionViewCellIdentifier)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        creditsCollectionView.addGestureRecognizer(longPressGesture)
    }
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            guard let selectedIndexPath = creditsCollectionView.indexPathForItem(at: gesture.location(in: creditsCollectionView)) else { break }
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                self?.showLoading()
                self?.viewModel.removeBank(documentId: (self?.viewModel.documentIds[selectedIndexPath.row])!)
                self?.viewModel.banks.remove(at: selectedIndexPath.row)
                self?.viewModel.documentIds.remove(at: selectedIndexPath.row)
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
    
    @objc func settingsButtonTapped() {
        
        guard let email = Auth.auth().currentUser?.email else { return }
        
        let alertController = UIAlertController(title: nil, message: "\n\(email)", preferredStyle: .actionSheet)

        let logoutAction = UIAlertAction(title: "Logout", style: .default) { [weak self] _ in
            self?.viewModel.userSignout()
        }
        alertController.addAction(logoutAction)

        let deleteAccountAction = UIAlertAction(title: "Delete Account", style: .destructive) { [weak self] _ in
            
            let alertController = UIAlertController(title: "Are you sure you want to delete account?", message: "There is no undo", preferredStyle: .alert)
            
            let deleteButton = UIAlertAction(title: "Delete", style: .destructive) { _ in
                self?.viewModel.removeAccount()
                self?.viewModel.deleteAccountDocuments()
                NotificationCenter.default.post(name: .signOutButtonTapped, object: nil)
                self?.presentAlert(title: "Succesfull", message: "Account and all data successfully removed", buttonTitle: "OK")
            }
            
            let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
            
            alertController.addAction(deleteButton)
            alertController.addAction(cancelButton)
            self?.present(alertController, animated: true)
            
            
        }
        alertController.addAction(deleteAccountAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        alertController.setValue(NSAttributedString(string: "\n\(email)", attributes: [.font: UIFont.systemFont(ofSize: 17), .foregroundColor: UIColor.black]), forKey: "attributedMessage")

        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = leftBarButton
        }

        present(alertController, animated: true, completion: nil)
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
        
        let addCreditVc = AddCreditViewController()
        addCreditVc.selectedCredit = viewModel.banks[indexPath.row]
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

extension CreditsMainViewController: CreditsMainViewModelDelegate {
    func handleViewModelOutput(_ result: Result<BankData, Error>) {
        switch result {
        case .success(let success):
            viewModel.banks = success.bankDetails
            viewModel.documentIds = success.stringArray
            
            if viewModel.banks.isEmpty {
                emptyState = DTEmptyStateView(message: "Currently don't have Bank\nAdd from (+)")
                emptyState?.frame = view.bounds
                view.addSubview(emptyState!)
                
            } else {
                emptyState?.removeFromSuperview()
            }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.creditsCollectionView.reloadData()
            }
            
            updateData(banks: viewModel.banks)
            
        case .failure(let failure):
            print("Önemsiz bir uyarı: \(failure.localizedDescription)")
        }
    }
}
