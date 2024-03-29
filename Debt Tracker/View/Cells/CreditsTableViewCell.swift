//
//  CreditsTableViewCell.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 27.01.2023.
//

import UIKit

class CreditsTableViewCell: UITableViewCell {
    
    var containerViewOne = UIView()
    var containerViewTwo = UIView()
    var containerViewThree = UIView()
    
    var nameLabel = DTTitleLabel(textAlignment: .left, fontSize: 14)
    var entryDebt = DTTitleLabel(textAlignment: .left, fontSize: 19)
    var paidCount = DTTitleLabel(textAlignment: .left, fontSize: 12, textColor: .label)
    var remainingCount = DTTitleLabel(textAlignment: .left, fontSize: 12, textColor: .label)
    var monthlyDepth = DTTitleLabel(textAlignment: .left, fontSize: 12, textColor: .label)
    var nextPayment = DTTitleLabel(textAlignment: .left, fontSize: 12, textColor: .label)
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
            
            if count == totalInstallmentCount{
                backgroundColor = .systemGreen
            } else {
                if traitCollection.userInterfaceStyle == .dark {
                    backgroundColor = .systemGray6
                    
                } else {
                    backgroundColor = .systemGray2
                }
            }
        }
    }
    
    let progressBar: UIProgressView = {
        let progressBar = UIProgressView()
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        return progressBar
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        applyConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(credit: CreditDetailModel) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = K.numberFormatterGroupingSeparator
        formatter.positiveSuffix = credit.currency
        
        nameLabel.text = "\(credit.name) - \(credit.detail)"
        entryDebt.text = credit.entryDebt
        
        totalInstallmentCount = Int(credit.installmentCount)
        count = Int(credit.paidCount)
        
        monthlyDepth.text = "Monthly Installment: \(credit.monthlyInstallment)"
        nextPayment.text = "Next Payment: \(credit.currentInstallmentDate)"
        totalDebt.text = credit.totalDebt
        paid.text = credit.paidDebt
        remaining.text = credit.remainingDebt
    }
    
    func applyConstraints() {
        nameLabel.numberOfLines = 2
        
        addSubviews(nameLabel, entryDebt, paidCount, remainingCount, progressBar, monthlyDepth, nextPayment, containerViewOne, containerViewTwo, containerViewThree)
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        containerViewOne.translatesAutoresizingMaskIntoConstraints = false
        containerViewTwo.translatesAutoresizingMaskIntoConstraints = false
        containerViewThree.translatesAutoresizingMaskIntoConstraints = false
        containerViewOne.backgroundColor = .systemGray4
        containerViewTwo.backgroundColor = .systemGray4
        containerViewThree.backgroundColor = .systemGray4
        accessoryType = .disclosureIndicator
        
        nameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
        
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
        
        nameLabel.trailingAnchor.constraint(equalTo: containerViewTwo.trailingAnchor, constant: -50).isActive = true
        monthlyDepth.trailingAnchor.constraint(equalTo: containerViewTwo.trailingAnchor, constant: -50).isActive = true

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
