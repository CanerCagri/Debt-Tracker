//
//  CreditsDetailViewController.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 27.01.2023.
//

import UIKit
import Firebase

class CreditsDetailViewController: UIViewController {
    
    var detailLabel = DTTitleLabel(textAlignment: .left, fontSize: 21)
    var paymentTitleLabel = DTTitleLabel(textAlignment: .left, fontSize: 18, text: "All Installments")
    var startAndEndTitleLabel = DTTitleLabel(textAlignment: .left, fontSize: 15)
    var detailTableView = UITableView()
    var totalDebtLabel = DTTitleLabel(textAlignment: .center, fontSize: 18, textColor: .black)
    var remainingDebtLabel = DTTitleLabel(textAlignment: .center, fontSize: 18, textColor: .black)
    var totalPaidDebtLabel = DTTitleLabel(textAlignment: .center, fontSize: 18, textColor: .black)
    var totalPaidMonthLabel = DTTitleLabel(textAlignment: .center, fontSize: 18, textColor: .black)
    var containerView = UIView()
    
    let db = Firestore.firestore()
    let dateFormatter = DateFormatter()
    var date = Date()
    var documentId: String!
    var viewModel = CreditsDetailViewModel()
    
    var creditModel: CreditDetailModel! {
        didSet
        {
            detailLabel.text = "\(creditModel.name) - \(creditModel.detail)"
            totalDebtLabel.addIcon(icon: UIImage(systemName: SFSymbols.creditCircleFill)!, text: "Total Debt: \(creditModel.totalDebt)", iconSize: CGSize(width: 20, height: 20), xOffset: -2, yOffset: -2)
            totalPaidDebtLabel.addIcon(icon: UIImage(systemName: SFSymbols.checkMarkFill)!, text: "Paid: \(creditModel.paidDebt)", iconSize: CGSize(width: 20, height: 20), xOffset: -2, yOffset: -2)
            remainingDebtLabel.addIcon(icon: UIImage(systemName: SFSymbols.dollarSignFill)!, text: "Remaining: \(creditModel.remainingDebt)", iconSize: CGSize(width: 20, height: 20), xOffset: -2, yOffset: -2)
            totalPaidMonthLabel.addIcon(icon: UIImage(systemName: SFSymbols.handsClapFill)!, text: "\(String(creditModel.paidCount))/\(String(creditModel.installmentCount)) paid", iconSize: CGSize(width: 20, height: 20), xOffset: -2, yOffset: -2)
            
            dateFormatter.dateFormat = K.creditsDetailVcDateFormat
            date = dateFormatter.date(from: creditModel.firstInstallmentDate)!
            
            let lastDate = Calendar.current.date(byAdding: .month, value: Int(creditModel.installmentCount) - 1, to: date)!
            let nextDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: lastDate)
            let dayString = String(format: K.dateFormatter02dFormat, nextDateComponents.day!)
            let monthString = String(format: K.dateFormatter02dFormat, nextDateComponents.month!)
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
        title = "Credit Detail"
        view.setBackgroundColor()
        viewModel.delegate = self
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = Colors.lightYellowColor
        containerView.layer.cornerRadius = 16
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissVC))
        
        navigationItem.rightBarButtonItem = doneButton
    }
    
    private func configureTableView() {
        detailTableView.delegate = self
        detailTableView.dataSource = self
        detailTableView.backgroundColor = .systemBackground
        detailTableView.layer.cornerRadius = 16
        detailTableView.layer.borderWidth = 2
        detailTableView.layer.borderColor = Colors.pastelBlueColor
        detailTableView.rowHeight = 40
        detailTableView.layer.cornerRadius = 14
        detailTableView.register(CreditsDetailTableViewCell.self, forCellReuseIdentifier:CreditsDetailTableViewCell.identifier)
    }
    
    @objc func dismissVC() { dismiss(animated: true) }
    
    func applyConstraints() {
        detailLabel.numberOfLines = 2
        
        view.addSubviews(containerView, detailLabel, paymentTitleLabel, startAndEndTitleLabel, detailTableView, totalDebtLabel, remainingDebtLabel, totalPaidDebtLabel, totalPaidMonthLabel)
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
        
        containerView.topAnchor.constraint(equalTo: detailTableView.bottomAnchor, constant: 10).isActive = true
        containerView.leadingAnchor.constraint(equalTo: detailTableView.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: detailTableView.trailingAnchor).isActive = true
        
        totalDebtLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20).isActive = true
        totalDebtLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        totalDebtLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        totalDebtLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        
        totalPaidDebtLabel.topAnchor.constraint(equalTo: totalDebtLabel.bottomAnchor, constant: 10).isActive = true
        totalPaidDebtLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        remainingDebtLabel.topAnchor.constraint(equalTo: totalPaidDebtLabel.bottomAnchor, constant: 10).isActive = true
        remainingDebtLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        remainingDebtLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        remainingDebtLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        
        totalPaidMonthLabel.topAnchor.constraint(equalTo: remainingDebtLabel.bottomAnchor, constant: 10).isActive = true
        totalPaidMonthLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        containerView.bottomAnchor.constraint(equalTo: totalPaidMonthLabel.bottomAnchor, constant: 20).isActive = true
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
            cell.backgroundColor = .systemYellow
            cell.contentView.alpha = 0.8
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
            let dayString = String(format: K.dateFormatter02dFormat, nextDateComponents.day!)
            let monthString = String(format: K.dateFormatter02dFormat, nextDateComponents.month!)
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
        let selectedCell = tableView.cellForRow(at: selectedIndexPath) as? CreditsDetailTableViewCell
        
        date = dateFormatter.date(from: selectedCell?.dateLabel.text! ?? "Error")!
        let selectedDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: date)
        let dayString = String(format: K.dateFormatter02dFormat, selectedDateComponents.day!)
        let monthString = String(format: K.dateFormatter02dFormat, selectedDateComponents.month!)
        let yearString = String(selectedDateComponents.year!)
        
        let selectedMonthDate = "\(dayString).\(monthString).\(yearString)"
        let selectedMonthCount = Int32((creditModel.paidCount)) + 1
        
        let calculatedPaid = Currency.formatCurrencyStringAsDouble(with: creditModel.locale, for: creditModel.monthlyInstallment, viewController: self, documentId: documentId) + Currency.formatCurrencyStringAsDouble(with: creditModel.locale, for: creditModel.paidDebt, viewController: self, documentId: documentId)
        let formattedPaid = String(format: K.string2fFormat, calculatedPaid)
        let selectedPaidDebt = Currency.currencyInputFormatting(with: creditModel.locale, for: String(formattedPaid))
        
        let calculatedRemainingDebt = Currency.formatCurrencyStringAsDouble(with: creditModel.locale, for: creditModel.remainingDebt, viewController: self, documentId: documentId) - Currency.formatCurrencyStringAsDouble(with: creditModel.locale, for: creditModel.monthlyInstallment, viewController: self, documentId: documentId)
        let formattedRemaining = String(format: K.string2fFormat, calculatedRemainingDebt)
        let selectedRemainingDebt = Currency.currencyInputFormatting(with: creditModel.locale, for: String(formattedRemaining))
        
        let viewModel = CreditDetailModel(name: creditModel.name, detail: creditModel.detail, entryDebt: creditModel.entryDebt, installmentCount: Int(creditModel.installmentCount), paidCount: Int(selectedMonthCount), monthlyInstallment: creditModel.monthlyInstallment, firstInstallmentDate: creditModel.firstInstallmentDate, currentInstallmentDate: selectedMonthDate, totalDebt: creditModel.totalDebt, interestRate: creditModel.interestRate, remainingDebt: selectedRemainingDebt, paidDebt: selectedPaidDebt, email: email, currency: creditModel.currency, locale: creditModel.locale)
        
        let yesAction = UIAlertAction(title: "Yes, I did pay selected Installment.", style: .default) { [weak self] (action) in
            self?.showLoading()
            self?.viewModel.editCredit(documentId: self?.documentId ?? "", viewModel: viewModel)
        }
        
        let noAction = UIAlertAction(title: "No, I didn't pay yet.", style: .cancel) { (action) in
            tableView.deselectRow(at: indexPath, animated: true)
        }
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        present(alert, animated: true)
    }
}

extension CreditsDetailViewController: CreditsDetailViewlModelDelegate {
    func handleViewModelOutput(_ result: Result<Void, Error>) {
        switch result {
        case .success(_):
            let alertController = UIAlertController(title: "Payment Successful", message: nil, preferredStyle: .alert)
            
            let deleteButton = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.dismissLoading()
                self?.dismissVC()
            }
            
            alertController.addAction(deleteButton)
            present(alertController, animated: true)
        case .failure(let failure):
            presentAlert(title: "Warning", message: failure.localizedDescription, buttonTitle: "OK")
        }
    }
}
