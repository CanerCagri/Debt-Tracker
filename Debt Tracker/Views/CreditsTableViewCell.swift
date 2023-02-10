//
//  CreditsTableViewCell.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 27.01.2023.
//

import UIKit

class CreditsTableViewCell: UITableViewCell {
    
    static let identifier = "CreditsTableViewCell"
    
    var containerViewOne = UIView()
    var containerViewTwo = UIView()
    var containerViewThree = UIView()
    
    var nameLabel = DTTitleLabel(textAlignment: .left, fontSize: 14)
    var entryDebt = DTTitleLabel(textAlignment: .left, fontSize: 17)
    var paidCount = DTTitleLabel(textAlignment: .left, fontSize: 12, textColor: .label)
    var remainingCount = DTTitleLabel(textAlignment: .left, fontSize: 12, textColor: .label)
    var monthlyDepth = DTTitleLabel(textAlignment: .left, fontSize: 12, textColor: .systemGray2)
    var nextPayment = DTTitleLabel(textAlignment: .left, fontSize: 12, textColor: .systemGray2)
    var totalDebtLabel = DTTitleLabel(textAlignment: .center, fontSize: 11, textColor: .systemGray2, text: "Total Debt")
    var totalDebt = DTTitleLabel(textAlignment: .center, fontSize: 14, textColor: .label)
    var paidLabel = DTTitleLabel(textAlignment: .center, fontSize: 11, textColor: .systemGray2, text: "Paid")
    var paid = DTTitleLabel(textAlignment: .center, fontSize: 14, textColor: .systemGreen)
    var remainingLabel = DTTitleLabel(textAlignment: .center, fontSize: 11, textColor: .systemGray2, text: "Remaining")
    var remaining = DTTitleLabel(textAlignment: .center, fontSize: 14, textColor: .systemRed)
    
    var totalInstallmentCount = 0
    var count = 0 {
        didSet {
            paidCount.text = "\(count) paid"
            remainingCount.text = "\(totalInstallmentCount - count) remaining"
            progressBar.setProgress(Float(count)/Float(Int(totalInstallmentCount)), animated: true)
        }
    }
    
    let progressBar: UIProgressView = {
        let progressBar = UIProgressView()
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        return progressBar
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    
        containerViewOne.backgroundColor = .systemGray5
        containerViewTwo.backgroundColor = .systemGray5
        containerViewThree.backgroundColor = .systemGray5
        
        applyConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(credit: CreditDetailModel) {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.currencySymbol = ""
        formatter.positiveSuffix = " ₺"
        
        nameLabel.text = "\(credit.name) - \(credit.detail) - %\(credit.interestRate)"

        let entryDebtFormatted = formatter.string(from: credit.entryDebt as NSNumber)
        entryDebt.text = entryDebtFormatted ?? ""
        
        totalInstallmentCount = Int(credit.installmentCount)
        count = Int(credit.paidCount)
        
        let monthlyFormatted = formatter.string(from: credit.monthlyInstallment as NSNumber)
        monthlyDepth.text = "Monthly Installment: \(monthlyFormatted ?? "")"
        
        nextPayment.text = "Next Payment: \(credit.currentInstallmentDate)"
        
        let totalDebtFormatted = formatter.string(from: credit.totalDebt as NSNumber)
        totalDebt.text = totalDebtFormatted ?? ""
        
        let totalPaidDebtFormatted = formatter.string(from: credit.paidDebt as NSNumber)
        paid.text = totalPaidDebtFormatted ?? ""
        
        let calculateRemaining = Double(credit.totalDebt) - credit.paidDebt
        let remainingTextFormatted = formatter.string(from: calculateRemaining as NSNumber)
        remaining.text = remainingTextFormatted ?? ""
    }
    
    
    func applyConstraints() {
        
        nameLabel.numberOfLines = 2
        
        addSubviews(nameLabel, entryDebt, paidCount, remainingCount, progressBar, monthlyDepth, nextPayment, containerViewOne, containerViewTwo, containerViewThree)
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        containerViewTwo.translatesAutoresizingMaskIntoConstraints = false
        containerViewThree.translatesAutoresizingMaskIntoConstraints = false
        containerViewOne.translatesAutoresizingMaskIntoConstraints = false
        accessoryType = .disclosureIndicator
        
        nameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -90).isActive = true
        
        entryDebt.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        entryDebt.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
        
        paidCount.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10).isActive = true
        paidCount.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
        
        remainingCount.topAnchor.constraint(equalTo: paidCount.topAnchor).isActive = true
        remainingCount.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
        
        progressBar.topAnchor.constraint(equalTo: paidCount.bottomAnchor, constant: 5).isActive = true
        progressBar.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
        progressBar.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
        progressBar.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
        monthlyDepth.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 5).isActive = true
        monthlyDepth.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
        
        nextPayment.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 5).isActive = true
        nextPayment.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
        
        constraintsOfContainers()
        constraintsInsideContainers()
    }
    
    func constraintsOfContainers() {
        let totalWidth = self.frame.width
        let labelWidth = totalWidth / 3
        
        containerViewTwo.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        containerViewTwo.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -15).isActive = true
        containerViewTwo.widthAnchor.constraint(equalToConstant: labelWidth).isActive = true
        containerViewTwo.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        containerViewOne.trailingAnchor.constraint(equalTo: containerViewTwo.leadingAnchor, constant: -2).isActive = true
        containerViewOne.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -15).isActive = true
        containerViewOne.widthAnchor.constraint(equalToConstant: labelWidth).isActive = true
        containerViewOne.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        containerViewThree.leadingAnchor.constraint(equalTo: containerViewTwo.trailingAnchor, constant: 2).isActive = true
        containerViewThree.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -15).isActive = true
        containerViewThree.widthAnchor.constraint(equalToConstant: labelWidth).isActive = true
        containerViewThree.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func constraintsInsideContainers() {
        containerViewOne.addSubviews(totalDebtLabel, totalDebt)
        
        totalDebtLabel.topAnchor.constraint(equalTo: containerViewOne.topAnchor, constant: 5).isActive = true
        totalDebtLabel.leadingAnchor.constraint(equalTo: containerViewOne.leadingAnchor).isActive = true
        totalDebtLabel.trailingAnchor.constraint(equalTo: containerViewOne.trailingAnchor).isActive = true
        
        totalDebt.topAnchor.constraint(equalTo: totalDebtLabel.bottomAnchor, constant: 5).isActive = true
        totalDebt.leadingAnchor.constraint(equalTo: containerViewOne.leadingAnchor).isActive = true
        totalDebt.trailingAnchor.constraint(equalTo: containerViewOne.trailingAnchor).isActive = true
        
        containerViewTwo.addSubviews(paidLabel, paid)
        
        paidLabel.topAnchor.constraint(equalTo: containerViewTwo.topAnchor, constant: 5).isActive = true
        paidLabel.leadingAnchor.constraint(equalTo: containerViewTwo.leadingAnchor).isActive = true
        paidLabel.trailingAnchor.constraint(equalTo: containerViewTwo.trailingAnchor).isActive = true
        
        paid.topAnchor.constraint(equalTo: paidLabel.bottomAnchor, constant: 5).isActive = true
        paid.leadingAnchor.constraint(equalTo: containerViewTwo.leadingAnchor).isActive = true
        paid.trailingAnchor.constraint(equalTo: containerViewTwo.trailingAnchor).isActive = true
        
        containerViewThree.addSubviews(remainingLabel, remaining)
        
        remainingLabel.topAnchor.constraint(equalTo: containerViewThree.topAnchor, constant: 5).isActive = true
        remainingLabel.leadingAnchor.constraint(equalTo: containerViewThree.leadingAnchor).isActive = true
        remainingLabel.trailingAnchor.constraint(equalTo: containerViewThree.trailingAnchor).isActive = true
        
        remaining.topAnchor.constraint(equalTo: remainingLabel.bottomAnchor, constant: 5).isActive = true
        remaining.leadingAnchor.constraint(equalTo: containerViewThree.leadingAnchor).isActive = true
        remaining.trailingAnchor.constraint(equalTo: containerViewThree.trailingAnchor).isActive = true
    }
}
