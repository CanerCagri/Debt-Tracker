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

    var creditsCollectionView: UICollectionView!
    
    var mockdata: [CreditDetailsModel] = [
                                          CreditDetailsModel(id: UUID().uuidString, name: "En Para", detail: "İhtiyaç Kredisi"),
                                          CreditDetailsModel(id: UUID().uuidString, name: "Akbank", detail: "Ev Kredisi"),
                                          CreditDetailsModel(id: UUID().uuidString, name: "Test Bank", detail: "Test Kredisi"),
        ]
    
    var dataSource: UICollectionViewDiffableDataSource <Section, CreditDetailsModel>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureViewController()
        configureCollectionView()
        configureDataSource()
        updateData(credits: mockdata)
    }
    
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        title = "Select Credit"
    }
    
    func configureCollectionView() {
        creditsCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UIHelper.createThreeColumnFlowLayout(view: view))
        view.addSubview(creditsCollectionView)
        creditsCollectionView.delegate = self
        creditsCollectionView.backgroundColor = .systemBackground
        creditsCollectionView.register(CreditsCollectionViewCell.self, forCellWithReuseIdentifier: CreditsCollectionViewCell.identifier)
       
    }
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, CreditDetailsModel>(collectionView: creditsCollectionView, cellProvider: { collectionView, indexPath, credit in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CreditsCollectionViewCell.identifier, for: indexPath) as! CreditsCollectionViewCell
            cell.set(credit: credit)
            return cell
        })
    }
    
    func updateData(credits: [CreditDetailsModel]) {
        var snapShot = NSDiffableDataSourceSnapshot<Section, CreditDetailsModel>()
        snapShot.appendSections([.main])
        snapShot.appendItems(credits)
        
        dataSource.apply(snapShot, animatingDifferences: true)
    }
}

extension CreditsAddDetailMainViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      
        collectionView.deselectItem(at: indexPath, animated: true)
        view.backgroundColor = .gray
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2 ) { [weak self] in
            let popupVc = CreditsPopupVc()
            popupVc.selectedCredit = self?.mockdata[indexPath.row]
            self?.addChild(popupVc)
            self?.view.addSubview(popupVc.view)
            popupVc.didMove(toParent: self)
           
        }
    }
}


