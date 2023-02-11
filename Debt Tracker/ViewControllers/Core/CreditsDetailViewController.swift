//
//  CreditsDetailViewController.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 27.01.2023.
//

import UIKit
import Firebase

class CreditsDetailViewController: UIViewController {
    
    let db = Firestore.firestore()
    
    var next12MonthsString: String?
    var calculatedRowCount: Int?
    var debtLabelText: Double?
    
    let formatter = NumberFormatter()
    let dateFormatter = DateFormatter()
    let calendar = Calendar.current
    var date = Date()
    
    var creditModel: CreditDetailModel! {
        didSet
        {
            formatter.numberStyle = .decimal
            
            formatter.locale = Locale(identifier: "tr_TR")
            formatter.currencySymbol = ""
            formatter.positiveSuffix = " ₺"
            
            title = creditModel.name
            next12MonthsString = creditModel.firstInstallmentDate
            calculatedRowCount = (Int(creditModel.installmentCount) - Int(creditModel.paidCount))

            detailLabel.text = creditModel.detail

            let totalDebtFormatted = formatter.string(from: creditModel.totalDebt as NSNumber)
            totalDebtLabel.text = "Total Debt: \(totalDebtFormatted ?? "Error")"

            let calculateRemaining = Double(creditModel.totalDebt) - creditModel.paidDebt
            let remainingTextFormatted = formatter.string(from: calculateRemaining as NSNumber)
            remainingDebtLabel.text = "Remaining Debt: \(remainingTextFormatted ?? "Error")"

            let totalPaidDebtFormatted = formatter.string(from: creditModel.paidDebt as NSNumber)
            totalPaidDebtLabel.text = "Paid Debt: \(totalPaidDebtFormatted ?? "Error")"
            totalPaidMonthLabel.text = "\(String(creditModel.paidCount))/\(String(creditModel.installmentCount)) paid"
        }
    }
    
    var detailLabel = DTTitleLabel(textAlignment: .left, fontSize: 18)
    var paymentTitleLabel = DTTitleLabel(textAlignment: .left, fontSize: 18, text: "All Installments")
    var startAndEndTitleLabel = DTTitleLabel(textAlignment: .left, fontSize: 15)
    var detailTableView = UITableView()
    var totalDebtLabel = DTTitleLabel(textAlignment: .center, fontSize: 18)
    var remainingDebtLabel = DTTitleLabel(textAlignment: .center, fontSize: 18)
    var totalPaidDebtLabel = DTTitleLabel(textAlignment: .center, fontSize: 18)
    var totalPaidMonthLabel = DTTitleLabel(textAlignment: .center, fontSize: 18)
    
    var selectedMonthDate: String?
    var selectedMonthCount: Int32?
    var selectedRemainingDebt: Double?
    var selectedPaidDebt: Double?
    var documentId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        configureTableView()
        applyConstraints()
        
        dateFormatter.dateFormat = "dd.MM.yyyy"
        date = dateFormatter.date(from: creditModel.firstInstallmentDate)!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.currencySymbol = ""
        formatter.positiveSuffix = " ₺"
    }
    
    private func configureTableView() {
        detailTableView.delegate = self
        detailTableView.dataSource = self
        detailTableView.rowHeight = 40
        detailTableView.layer.cornerRadius = 14
        detailTableView.register(CreditsDetailTableViewCell.self, forCellReuseIdentifier:CreditsDetailTableViewCell.identifier)
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
        
        detailTableView.topAnchor.constraint(equalTo: paymentTitleLabel.bottomAnchor, constant: 10).isActive = true
        detailTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        detailTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        detailTableView.heightAnchor.constraint(equalToConstant: 400).isActive = true
        
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
        cell.nameLabel.text = "\(indexPath.row + 1). month:"

        let priceLabelTextFormatted = formatter.string(from: creditModel.monthlyInstallment as NSNumber)
        cell.priceLabel.text = priceLabelTextFormatted

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

        if indexPath.row == creditModel.installmentCount - 3{

            let lastDate = Calendar.current.date(byAdding: .month, value: Int(creditModel.installmentCount) - 1, to: date)!
            let nextDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: lastDate)
            let dayString = String(format: "%02d", nextDateComponents.day!)
            let monthString = String(format: "%02d", nextDateComponents.month!)
            let yearString = String(nextDateComponents.year!)
            startAndEndTitleLabel.text = "\(creditModel.firstInstallmentDate) - \(dayString).\(monthString).\(yearString)"
        }
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let email = Auth.auth().currentUser?.email else { return }
        
        let alert = UIAlertController(title: "Payment", message: nil, preferredStyle: .actionSheet)

        let nextIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
        let nextCell = tableView.cellForRow(at: nextIndexPath) as! CreditsDetailTableViewCell

        date = dateFormatter.date(from: nextCell.dateLabel.text!)!
        let nextDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: date)
        let dayString = String(format: "%02d", nextDateComponents.day!)
        let monthString = String(format: "%02d", nextDateComponents.month!)
        let yearString = String(nextDateComponents.year!)

        self.selectedMonthDate = "\(dayString).\(monthString).\(yearString)"
        self.selectedMonthCount = Int32((self.creditModel.paidCount)) + 1
        self.selectedPaidDebt = creditModel.monthlyInstallment + creditModel.paidDebt
        self.selectedRemainingDebt = creditModel.monthlyInstallment - self.creditModel.remainingDebt

        let viewModel = CreditDetailModel(name: (self.creditModel.name), detail: (self.creditModel.detail), entryDebt: Int((self.creditModel.entryDebt)), installmentCount: Int((self.creditModel.installmentCount)), paidCount: Int((self.selectedMonthCount!)), monthlyInstallment: (self.creditModel.monthlyInstallment), firstInstallmentDate: (self.creditModel.firstInstallmentDate), currentInstallmentDate: (self.selectedMonthDate!), totalDebt: (self.creditModel.totalDebt), interestRate: (self.creditModel.interestRate), remainingDebt: (self.selectedRemainingDebt!), paidDebt: self.selectedPaidDebt!, email: email)

        let yesAction = UIAlertAction(title: "Yes, I did pay selected Installment.", style: .default) { [weak self] (action) in
            
            FirestoreManager.shared.editCredit(documentId: (self?.documentId)!, viewModel: viewModel) { result in
                switch result {
                case .success(_):
                    print("succesfully paid")
                case .failure(let failure):
                    print(failure.localizedDescription)
                }
            }
            let alertController = UIAlertController(title: "Payment Succesfull", message: nil, preferredStyle: .alert)

            let deleteButton = UIAlertAction(title: "OK", style: .default) { _ in
                self?.navigationController?.popToRootViewController(animated: true)
            }

            alertController.addAction(deleteButton)
            self?.present(alertController, animated: true)
        }

        let noAction = UIAlertAction(title: "No, I didnt pay yet.", style: .cancel) { (action) in
            tableView.deselectRow(at: indexPath, animated: true)
        }

        alert.addAction(yesAction)
        alert.addAction(noAction)

        self.present(alert, animated: true, completion: nil)
    }
}
