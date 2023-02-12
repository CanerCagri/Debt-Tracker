//
//  CreditsPopupVc.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 1.02.2023.
//

import UIKit
import Firebase

class CreditsPopupVc: UIViewController {
    
    let db = Firestore.firestore()
    
    let moodSelectionVc = CreditsBottomSheetVc()
    var selectedCredit: BankDetails? {
        didSet {
            creditNameLabel.text = selectedCredit?.name
            creditDetailLabel.text = selectedCredit?.detail
        }
    }
    
    private let containerView = DTContainerView()
    let titleLabel = DTTitleLabel(textAlignment: .center, fontSize: 18, textColor: .label, text: "Add Credit")
    let saveButton = DTButton(title: "Save", color: .systemPink, systemImageName: "square.and.arrow.down")
    
    let creditNameLabel = DTTitleLabel(textAlignment: .left, fontSize: 25)
    let creditDetailLabel = DTTitleLabel(textAlignment: .left, fontSize: 18)
    
    let amountTextField = DTTextField(placeholder: "Enter Amount", placeHolderSize: 15)
    let monthlyTextField = DTTextField(placeholder: "Enter Monthly Installment", placeHolderSize: 15)
    
    let monthlyInstallmentCountLabel = DTTitleLabel(textAlignment: .left, fontSize: 15, text: "Select Number Of Installments:")
    var monthlyInstallmentCountButton = DTButton(title: "12", color: .systemRed)
    
    let rateLabel = DTTitleLabel(textAlignment: .left, fontSize: 18, textColor: .systemGray, text: "Interest Rate: ")
    let rateResultLabel = DTTitleLabel(textAlignment: .left, fontSize: 18, textColor: .systemGray, text: "%0.0")
    
    let totalPaymentLabel = DTTitleLabel(textAlignment: .left, fontSize: 18, textColor: .systemGray, text: "Total Payment:")
    let totalPaymentResultLabel = DTTitleLabel(textAlignment: .left, fontSize: 18, textColor: .systemGray, text: "0 ₺")
    
    let firstInstallmentLabel = DTTitleLabel(textAlignment: .left, fontSize: 15, text: "Select First Installment:")
    let firstInstallmentDatePicker = UIDatePicker()
    
    private var closeButton: UIButton = {
        var button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.imageView?.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.imageView?.widthAnchor.constraint(equalToConstant: 44).isActive = true
        return button
    }()
    
    var monthCount = 12
    var firstInstallmentDate = ""
    var interestRateCalculated = ""
    var calculatedPayment = 0.0
    
    let formatter = NumberFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        applyConstraints()
    }
    
    private func configureViewController() {
        view.backgroundColor = UIColor.systemGray.withAlphaComponent(0.5)
        view.frame = UIScreen.main.bounds
        
        firstInstallmentDatePicker.datePickerMode = .date
        firstInstallmentDatePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        
        datePickerValueChanged(sender: firstInstallmentDatePicker)
        
        closeButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        monthlyInstallmentCountButton.addTarget(self, action: #selector(openBottomSheet), for: .touchUpInside)
        amountTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        monthlyTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("nextTapped"), object: nil, queue: nil) { [weak self] (notification) in
            self?.monthCount = (notification.userInfo?["selectedCount"] as? Int)!
            self?.monthlyInstallmentCountButton.setTitle(String(self!.monthCount), for: .normal)
            self?.calculateRateAndTotalPayment()
        }
    }
    @objc func saveButtonTapped() {
        guard let amount = amountTextField.text, !amount.isEmpty else {
            presentAlert(title: "Warning", message: "Please enter a Price", buttonTitle: "Ok")
            return
        }
        guard let monthly = monthlyTextField.text, !monthly.isEmpty else {
            presentAlert(title: "Warning", message: "Please enter a Monthly Installment Price", buttonTitle: "Ok")
            return
        }
        
        guard let userEmail = Auth.auth().currentUser?.email else {
            return
        }
        
        let creditModel = CreditDetailModel(name: creditNameLabel.text!, detail: creditDetailLabel.text!, entryDebt: Int(amount)!, installmentCount: monthCount, paidCount: 0, monthlyInstallment: Double(monthly)!, firstInstallmentDate: firstInstallmentDate, currentInstallmentDate: firstInstallmentDate, totalDebt: calculatedPayment, interestRate: Double(interestRateCalculated)!, remainingDebt: calculatedPayment, paidDebt: 0.0, email: userEmail)
        
        FirestoreManager.shared.createCredit(creditModel: creditModel) { [weak self] result in
            switch result {
            case .success(_):
                self?.animateOut()
                
                if let tabBarController = self?.tabBarController {
                    tabBarController.selectedIndex = 1
                }
            case .failure(let failure):
                self?.presentAlert(title: "Warning", message: failure.localizedDescription, buttonTitle: "OK")
            }
        }
    }
    
    @objc func dismissVC() {
        animateOut()
    }
    
    @objc func datePickerValueChanged(sender: UIDatePicker){
        let selectedDate = sender.date
        let calendar = Calendar.current
        let day = calendar.component(.day, from: selectedDate)
        let month = calendar.component(.month, from: selectedDate)
        let year = calendar.component(.year, from: selectedDate)
        
        let calculatedDay = String(format: "%02d", day)
        let calculatedMonth = String(format: "%02d", month)
        
        firstInstallmentDate = "\(calculatedDay).\(calculatedMonth).\(year)"
        print(firstInstallmentDate)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        calculateRateAndTotalPayment()
    }
    
    func calculateRateAndTotalPayment() {
        guard let amount = amountTextField.text, !amount.isEmpty else { return }
        guard let monthly = monthlyTextField.text, !monthly.isEmpty else { return }
        
        formatter.numberStyle = .decimal
        
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.currencySymbol = ""
        formatter.positiveSuffix = " ₺"
        
        calculatedPayment =  Double(monthlyTextField.text!)! * Double(monthCount)
        let remainingTextFormatted = formatter.string(from: calculatedPayment as NSNumber)
        totalPaymentResultLabel.text = "\(remainingTextFormatted ?? "Error")"
        
        let interestPrice = calculatedPayment - Double(amountTextField.text!)!
        let interestRate = (interestPrice / Double(amountTextField.text!)!) * Double(monthCount)
        interestRateCalculated = "\(String(format: "%.2f", interestRate))"
        rateResultLabel.text = "%\(interestRateCalculated)"
    }
    
    func animateOut() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseIn) { [weak self] in
            self?.containerView.transform = CGAffineTransform(translationX: 0, y: -(self?.view.frame.height)!)
            self?.view.alpha = 0
        } completion: { complete in
            if complete {
                self.view.removeFromSuperview()
            }
        }
    }
    
    func animateIn() {
        self.containerView.transform = CGAffineTransform(translationX: 0, y: -self.view.frame.height)
        self.view.alpha = 0
        
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseIn) {
            self.containerView.transform = .identity
            self.view.alpha = 1
        }
        
    }
    
    @objc func openBottomSheet() {
        
        if let sheet = moodSelectionVc.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.preferredCornerRadius = 24
        }
        
        present(moodSelectionVc, animated: true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.textAlignment = .center
    }
    
    private func applyConstraints() {
        animateIn()
        view.addSubview(containerView)
        containerView.backgroundColor = .systemGray5
        firstInstallmentDatePicker.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.82).isActive = true
        containerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.62).isActive = true
        
        containerView.addSubviews(titleLabel, closeButton, saveButton, creditNameLabel, creditDetailLabel, amountTextField, monthlyTextField, monthlyInstallmentCountLabel, monthlyInstallmentCountButton, firstInstallmentLabel, firstInstallmentDatePicker, rateLabel, rateResultLabel, totalPaymentLabel, totalPaymentResultLabel)
        
        let totalWidth = view.frame.width
        let textFieldWidth = totalWidth / 1.5
        
        titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        
        closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 2).isActive = true
        closeButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 2).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        
        saveButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5).isActive = true
        saveButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -5).isActive = true
        
        creditNameLabel.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 20).isActive = true
        creditNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20).isActive = true
        creditNameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20).isActive = true
        
        creditDetailLabel.topAnchor.constraint(equalTo: creditNameLabel.bottomAnchor, constant: 10).isActive = true
        creditDetailLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20).isActive = true
        creditDetailLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20).isActive = true
        
        amountTextField.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        amountTextField.topAnchor.constraint(equalTo: creditDetailLabel.bottomAnchor, constant: 15).isActive = true
        amountTextField.widthAnchor.constraint(equalToConstant: textFieldWidth ).isActive = true
        amountTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        monthlyTextField.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        monthlyTextField.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 5).isActive = true
        monthlyTextField.widthAnchor.constraint(equalToConstant: textFieldWidth).isActive = true
        monthlyTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        monthlyInstallmentCountLabel.topAnchor.constraint(equalTo: monthlyTextField.bottomAnchor, constant: 30).isActive = true
        monthlyInstallmentCountLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20).isActive = true
        
        monthlyInstallmentCountButton.topAnchor.constraint(equalTo: monthlyTextField.bottomAnchor, constant: 15).isActive = true
        monthlyInstallmentCountButton.leadingAnchor.constraint(equalTo: monthlyInstallmentCountLabel.trailingAnchor, constant: 15).isActive = true
        monthlyInstallmentCountButton.trailingAnchor.constraint(equalTo: saveButton.trailingAnchor).isActive = true
        monthlyInstallmentCountButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        firstInstallmentLabel.topAnchor.constraint(equalTo: monthlyInstallmentCountButton.bottomAnchor, constant: 17).isActive = true
        firstInstallmentLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20).isActive = true
        
        firstInstallmentDatePicker.topAnchor.constraint(equalTo: monthlyInstallmentCountButton.bottomAnchor, constant: 10).isActive = true
        firstInstallmentDatePicker.leadingAnchor.constraint(equalTo: firstInstallmentLabel.trailingAnchor, constant: 10).isActive = true
        firstInstallmentDatePicker.trailingAnchor.constraint(equalTo: monthlyInstallmentCountButton.trailingAnchor).isActive = true
        
        rateLabel.topAnchor.constraint(equalTo: firstInstallmentDatePicker.bottomAnchor, constant: 40).isActive = true
        rateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20).isActive = true
        
        rateResultLabel.topAnchor.constraint(equalTo: firstInstallmentDatePicker.bottomAnchor, constant: 40).isActive = true
        rateResultLabel.trailingAnchor.constraint(equalTo: monthlyTextField.trailingAnchor).isActive = true
        
        totalPaymentLabel.topAnchor.constraint(equalTo: rateLabel.bottomAnchor, constant: 15).isActive = true
        totalPaymentLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20).isActive = true
        
        totalPaymentResultLabel.topAnchor.constraint(equalTo: rateLabel.bottomAnchor, constant: 15).isActive = true
        totalPaymentResultLabel.trailingAnchor.constraint(equalTo: rateResultLabel.trailingAnchor).isActive = true
    }
}
