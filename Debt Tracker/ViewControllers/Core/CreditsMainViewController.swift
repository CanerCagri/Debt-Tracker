//
//  CreditsAddDetailMainVc.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 1.02.2023.
//

import UIKit
import Firebase

class CreditsMainViewController: UIViewController {
    enum Section {
        case main
    }
    
    let db = Firestore.firestore()
    var documentIds: [String] = []
    
    private var banks: [BankDetails] = []
    var emptyState: DTEmptyStateView?
    
    var creditsCollectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource <Section, BankDetails>!
    var isRightBarButtonTapped = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        configureCollectionView()
        configureDataSource()
        fetchFromFirestore()
    }
    
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        title = "Create Credit"
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "power"), style: .done, target: self, action: #selector(logoutButtonTapped)),
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(rightBarButtonTapped))
        ]
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("popupButtonTapped"), object: nil, queue: nil) { [weak self] (notification) in
            self?.isRightBarButtonTapped = false
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
    
    private func fetchFromFirestore() {
      
        db.collection("banks").order(by: "date", descending: true).addSnapshotListener { [weak self] querySnapShot, error in
            
            self?.banks = []
            
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let querySnapShotDocuments = querySnapShot?.documents {
                    for doc in querySnapShotDocuments {
                        let data = doc.data()
                       
                        if let name = data["name"] as? String, let detail = data["detail"] as? String, let email = data["email"] as? String {
                            
                            if email == Auth.auth().currentUser?.email {
                                
                                let bankModel = BankDetails(name: name, detail: detail, email: email)
                                self?.banks.append(bankModel)
                                self?.documentIds.append(doc.documentID)
                            }
                        }
                    }
                }
            }
            
            if self!.banks.isEmpty {
                self?.emptyState = DTEmptyStateView(message: "Currently don't have a Bank\nAdd from (+)")
                self?.emptyState?.frame = (self?.view.bounds)!
                self?.view.addSubview((self?.emptyState!)!)
                
                DispatchQueue.main.async {
                    self?.creditsCollectionView.reloadData()
                }
                
                self?.updateData(banks: self!.banks)
            } else {
                self?.emptyState?.removeFromSuperview()
                
                DispatchQueue.main.async {
                    self?.creditsCollectionView.reloadData()
                }
                
                self?.updateData(banks: self!.banks)
            }
            
        }
    }
    
    func deleteDocument(documentId: String) {
        let documentRef = db.collection("banks").document(documentId)

        documentRef.delete { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
               print("Succesfully removed")
            }
        }
    }
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            guard let selectedIndexPath = creditsCollectionView.indexPathForItem(at: gesture.location(in: creditsCollectionView)) else { break }
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                self.deleteDocument(documentId: self.documentIds[selectedIndexPath.row])
                self.banks.remove(at: selectedIndexPath.row)
                self.documentIds.remove(at: selectedIndexPath.row)
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
    
    @objc func logoutButtonTapped() {
        do {
            try Auth.auth().signOut()
            NotificationCenter.default.post(name: .didTapRightBarButton , object: nil)
            
        } catch let signOutError as NSError {
            print("Error when signing out: %@", signOutError)
        }
    }
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, BankDetails>(collectionView: creditsCollectionView, cellProvider: { collectionView, indexPath, banks in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CreditsCollectionViewCell.identifier, for: indexPath) as! CreditsCollectionViewCell
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2 ) { [weak self] in
            let popupVc = CreditsPopupVc()
            popupVc.selectedCredit = self?.banks[indexPath.row]
            self?.addChild(popupVc)
            self?.view.addSubview(popupVc.view)
            popupVc.didMove(toParent: self)
            
        }
    }
}


