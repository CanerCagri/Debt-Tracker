//
//  CreditsDetailViewController.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 27.01.2023.
//

import UIKit

class CreditsDetailViewController: UIViewController {
    
    var next12MonthsString: String?
    var calculatedRowCount: Int?
    
    var creditModel: CreditItems! {
        didSet
        {
            title = creditModel.name
            next12MonthsString = creditModel.payment_date
            calculatedRowCount = (12 - Int(creditModel.paid_count))
            remainingDebtLabel.text = "Remaining Debt: \(String(creditModel.remaining_debt))"
            totalPaidMonth.text = "Total Number Of Paid Months: \(String(creditModel.paid_count))"
        }
    }
    
    var paymentTitleLabel = DTTitleLabel(textAlignment: .left, fontSize: 20)
    var detailTableView = UITableView()
    var remainingDebtLabel = DTTitleLabel(textAlignment: .center, fontSize: 18)
    var totalPaidMonth = DTTitleLabel(textAlignment: .center, fontSize: 18)
    
    let dateFormatter = DateFormatter()
    var date = Date()
    let calendar = Calendar.current
    var next12Months = Date()
    
   
    var selectedMonthDate: String?
    var selectedMonthCount: Int32?
    var selectedRemainingDebt: Double?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        
        configureTableView()
        applyConstraints()
        
        paymentTitleLabel.text = "Pay Installment"
        dateFormatter.dateFormat = "dd.MM.yyyy"
        date = dateFormatter.date(from: creditModel.payment_date!)!
        next12Months = date
   
    }
    
    private func configureTableView() {
        detailTableView.delegate = self
        detailTableView.dataSource = self
        detailTableView.rowHeight = 40
        detailTableView.register(CreditsDetailTableViewCell.self, forCellReuseIdentifier:CreditsDetailTableViewCell.identifier)
        
    }
    
    func applyConstraints() {
        view.addSubviews(paymentTitleLabel, detailTableView, remainingDebtLabel, totalPaidMonth)
        detailTableView.translatesAutoresizingMaskIntoConstraints = false
        
        paymentTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5).isActive = true
        paymentTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        
        
        detailTableView.topAnchor.constraint(equalTo: paymentTitleLabel.bottomAnchor, constant: 10).isActive = true
        detailTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        detailTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        detailTableView.heightAnchor.constraint(equalToConstant: 400).isActive = true
        
        remainingDebtLabel.topAnchor.constraint(equalTo: detailTableView.bottomAnchor, constant: 10).isActive = true
        remainingDebtLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        totalPaidMonth.topAnchor.constraint(equalTo: remainingDebtLabel.bottomAnchor, constant: 10).isActive = true
        totalPaidMonth.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
}

extension CreditsDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calculatedRowCount!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CreditsDetailTableViewCell.identifier) as! CreditsDetailTableViewCell
        
        cell.nameLabel.text = "\(indexPath.row + Int(creditModel.paid_count) + 1). month:"
        cell.priceLabel.text = String(creditModel.montly_debt)
        
        if cell.dateLabel.text == nil || cell.dateLabel.text == "" {
            cell.dateLabel.text = next12MonthsString
            next12Months = calendar.date(byAdding: .month, value: 1, to: next12Months)!
            next12MonthsString = dateFormatter.string(from: next12Months)
        }
        
        if indexPath.row == 0 {
            cell.isUserInteractionEnabled = true
        } else {
            cell.isUserInteractionEnabled = false
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Payment", message: nil, preferredStyle: .actionSheet)
        
        let selectedCell = tableView.cellForRow(at: indexPath) as! CreditsDetailTableViewCell
        date = dateFormatter.date(from: creditModel.payment_date!)!
        next12Months = date
        next12Months = calendar.date(byAdding: .month, value: 1, to: next12Months)!
        next12MonthsString = dateFormatter.string(from: next12Months)
        
        self.selectedMonthDate = next12MonthsString
        self.selectedMonthCount = (self.creditModel.paid_count) + 1
        self.selectedRemainingDebt = (Double(selectedCell.priceLabel.text!)! - (self.creditModel.remaining_debt))
        

        let viewModel = CreditModel(id: (self.creditModel.id!), name: (self.creditModel.name!), entryDebt: Int((self.creditModel.entry_debt)), paidCount: Int((self.selectedMonthCount!)), monthlyDebt: (self.creditModel.montly_debt), paymentDate: (self.selectedMonthDate!), currentDebt: Int((self.creditModel.current_debt)), remainingDebt: (self.selectedRemainingDebt!))

        let yesAction = UIAlertAction(title: "Yes, I did pay selected Installment.", style: .default) { [weak self] (action) in
            
            PersistenceManager.shared.editCreditDetails(model: viewModel)
            NotificationCenter.default.post(Notification(name: Notification.Name("paymentUpdated")))
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            cell.backgroundColor = UIColor.systemGreen
        }
    }
}
