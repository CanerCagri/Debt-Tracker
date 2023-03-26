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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        configureCollectionView()
        configureDataSource()
        viewModel.fetchBanks()
    }
    
    private func configureViewController() {
        title = "Create Credit"
        view.backgroundColor = Colors.lightModeColor
        viewModel.delegate = self
        
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
    
    @objc func logoutButtonTapped() {
        viewModel.userSignout()
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
