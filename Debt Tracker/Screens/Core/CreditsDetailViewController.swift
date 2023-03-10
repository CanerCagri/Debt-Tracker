//
//  CreditsDetailViewController.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 27.01.2023.
//

import UIKit
import Firebase

class CreditsDetailViewController: UIViewController {
    
    var detailLabel = DTTitleLabel(textAlignment: .left, fontSize: 23)
    var paymentTitleLabel = DTTitleLabel(textAlignment: .left, fontSize: 18, text: "All Installments")
    var startAndEndTitleLabel = DTTitleLabel(textAlignment: .left, fontSize: 15)
    var detailTableView = UITableView()
    var totalDebtLabel = DTTitleLabel(textAlignment: .center, fontSize: 18)
    var remainingDebtLabel = DTTitleLabel(textAlignment: .center, fontSize: 18)
    var totalPaidDebtLabel = DTTitleLabel(textAlignment: .center, fontSize: 18)
    var totalPaidMonthLabel = DTTitleLabel(textAlignment: .center, fontSize: 18)
    
    let db = Firestore.firestore()
    let dateFormatter = DateFormatter()
    var date = Date()
    var documentId: String!
    
    var creditModel: CreditDetailModel! {
        didSet
        {
            detailLabel.text = "\(creditModel.detail) - \(creditModel.detail) - %\(creditModel.interestRate)"
            totalDebtLabel.text = "Total Debt: \(creditModel.totalDebt)"
            remainingDebtLabel.text = "Remaining: \(creditModel.remainingDebt)"
            totalPaidDebtLabel.text = "Paid: \(creditModel.paidDebt)"
            totalPaidMonthLabel.text = "\(String(creditModel.paidCount))/\(String(creditModel.installmentCount)) paid"
            
            
            dateFormatter.dateFormat = "dd.MM.yyyy"
            date = dateFormatter.date(from: creditModel.firstInstallmentDate)!
            
            let lastDate = Calendar.current.date(byAdding: .month, value: Int(creditModel.installmentCount) - 1, to: date)!
            let nextDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: lastDate)
            let dayString = String(format: "%02d", nextDateComponents.day!)
            let monthString = String(format: "%02d", nextDateComponents.month!)
            let yearString = String(nextDateComponents.year!)
            startAndEndTitleLabel.text = "\(creditModel.firstInstallmentDate) - \(dayString).\(monthString).\(yearString)"
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        configureTableView()
        applyConstraints()
    }
    
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissVC))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    private func configureTableView() {
        detailTableView.delegate = self
        detailTableView.dataSource = self
        detailTableView.rowHeight = 40
        detailTableView.layer.cornerRadius = 14
        detailTableView.register(CreditsDetailTableViewCell.self, forCellReuseIdentifier:CreditsDetailTableViewCell.identifier)
    }
    
    @objc func dismissVC() {
        dismiss(animated: true)
    }
    
    func applyConstraints() {
        detailLabel.numberOfLines = 2
        
        view.addSubviews(detailLabel, paymentTitleLabel, startAndEndTitleLabel, detailTableView, totalDebtLabel, remainingDebtLabel, totalPaidDebtLabel, totalPaidMonthLabel)
        detailTableView.translatesAutoresizingMaskIntoConstraints = false
        
        detailLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5).isActive = true
        detailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        detailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        
        paymentTitleLabel.topAnchor.constraint(equalTo: detailLabel.bottomAnchor, constant: 30).isActive = true
        paymentTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        
        startAndEndTitleLabel.topAnchor.constraint(equalTo: paymentTitleLabel.topAnchor, constant: 5).isActive = true
        startAndEndTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        
        let tableViewHeight: CGFloat = DeviceTypes.isiPhoneSE || DeviceTypes.isiPhone8PlusZoomed || DeviceTypes.isiPhone8Standard || DeviceTypes.isiPhone8Zoomed || DeviceTypes.isiPhone8PlusStandard ? 285 : 400
        
        
        detailTableView.topAnchor.constraint(equalTo: paymentTitleLabel.bottomAnchor, constant: 10).isActive = true
        detailTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        detailTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        detailTableView.heightAnchor.constraint(equalToConstant: tableViewHeight).isActive = true
        
        totalDebtLabel.topAnchor.constraint(equalTo: detailTableView.bottomAnchor, constant: 10).isActive = true
        totalDebtLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        totalPaidDebtLabel.topAnchor.constraint(equalTo: totalDebtLabel.bottomAnchor, constant: 10).isActive = true
        totalPaidDebtLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        remainingDebtLabel.topAnchor.constraint(equalTo: totalPaidDebtLabel.bottomAnchor, constant: 10).isActive = true
        remainingDebtLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        totalPaidMonthLabel.topAnchor.constraint(equalTo: remainingDebtLabel.bottomAnchor, constant: 10).isActive = true
        totalPaidMonthLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
}

extension CreditsDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return creditModel.installmentCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CreditsDetailTableViewCell.identifier) as! CreditsDetailTableViewCell
        cell.nameLabel.text = "Installment \(indexPath.row + 1)."
        
        cell.priceLabel.text = creditModel.monthlyInstallment
        
        cell.layer.cornerRadius = 8
        if indexPath.row < creditModel.paidCount {
            cell.backgroundColor = .systemGreen
            cell.isUserInteractionEnabled = false
        } else if indexPath.row == creditModel.paidCount {
            cell.backgroundColor = .systemGray3
            cell.isUserInteractionEnabled = true
        } else {
            cell.backgroundColor = .systemRed
            cell.isUserInteractionEnabled = false
        }
        
        if indexPath.row == 0 {
            cell.dateLabel.text = creditModel.firstInstallmentDate
        } else {
            
            let nextDate = Calendar.current.date(byAdding: .month, value: indexPath.row, to: date)!
            let nextDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: nextDate)
            let dayString = String(format: "%02d", nextDateComponents.day!)
            let monthString = String(format: "%02d", nextDateComponents.month!)
            let yearString = String(nextDateComponents.year!)
            cell.dateLabel.text = "\(dayString).\(monthString).\(yearString)"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let email = Auth.auth().currentUser?.email else { return }
        
        let alert = UIAlertController(title: "Payment", message: nil, preferredStyle: .actionSheet)
        
        let isLastRow = indexPath.row + 1 == creditModel.installmentCount
        
        let selectedIndexPath = isLastRow ? indexPath : IndexPath(row: indexPath.row + 1, section: indexPath.section)
        let selectedCell = tableView.cellForRow(at: selectedIndexPath) as! CreditsDetailTableViewCell
        
        date = dateFormatter.date(from: selectedCell.dateLabel.text!)!
        let selectedDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: date)
        let dayString = String(format: "%02d", selectedDateComponents.day!)
        let monthString = String(format: "%02d", selectedDateComponents.month!)
        let yearString = String(selectedDateComponents.year!)
        
        let selectedMonthDate = "\(dayString).\(monthString).\(yearString)"
        let selectedMonthCount = Int32((creditModel.paidCount)) + 1
        
        let calculatedPaid = Currency.formatCurrencyStringAsDouble(with: creditModel.locale, for: creditModel.monthlyInstallment, viewController: self, documentId: documentId) + Currency.formatCurrencyStringAsDouble(with: creditModel.locale, for: creditModel.paidDebt, viewController: self, documentId: documentId)
        let formattedPaid = String(format: "%.2f", calculatedPaid)
        let selectedPaidDebt = Currency.currencyInputFormatting(with: creditModel.locale, for: String(formattedPaid))
        
        let calculatedRemainingDebt = Currency.formatCurrencyStringAsDouble(with: creditModel.locale, for: creditModel.remainingDebt, viewController: self, documentId: documentId) - Currency.formatCurrencyStringAsDouble(with: creditModel.locale, for: creditModel.monthlyInstallment, viewController: self, documentId: documentId)
        let formattedRemaining = String(format: "%.2f", calculatedRemainingDebt)
        let selectedRemainingDebt = Currency.currencyInputFormatting(with: creditModel.locale, for: String(formattedRemaining))
        
        let viewModel = CreditDetailModel(name: creditModel.name, detail: creditModel.detail, entryDebt: creditModel.entryDebt, installmentCount: Int(creditModel.installmentCount), paidCount: Int(selectedMonthCount), monthlyInstallment: creditModel.monthlyInstallment, firstInstallmentDate: creditModel.firstInstallmentDate, currentInstallmentDate: selectedMonthDate, totalDebt: creditModel.totalDebt, interestRate: creditModel.interestRate, remainingDebt: selectedRemainingDebt, paidDebt: selectedPaidDebt, email: email, currency: creditModel.currency, locale: creditModel.locale)
        
        let yesAction = UIAlertAction(title: "Yes, I did pay selected Installment.", style: .default) { [weak self] (action) in
            
            FirestoreManager.shared.editCredit(documentId: self?.documentId ?? "", viewModel: viewModel) { result in
                switch result {
                case .success(_):
                    print("successfully paid")
                case .failure(let failure):
                    self?.presentAlert(title: "Warning", message: failure.localizedDescription, buttonTitle: "OK")
                }
            }
            let alertController = UIAlertController(title: "Payment Successful", message: nil, preferredStyle: .alert)
            
            let deleteButton = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.dismissVC()
            }
            
            alertController.addAction(deleteButton)
            self?.present(alertController, animated: true)
        }
        
        let noAction = UIAlertAction(title: "No, I didn't pay yet.", style: .cancel) { (action) in
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        present(alert, animated: true)
    }
}
