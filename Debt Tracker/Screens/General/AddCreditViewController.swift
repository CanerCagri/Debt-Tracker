//
//  CreditsPopupVc.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 1.02.2023.
//

import UIKit
import Firebase

class AddCreditViewController: UIViewController {
    
    var selectedCredit: BankDetails? {
        didSet {
            creditNameLabel.text = "\(selectedCredit?.name ?? "Error") - \(selectedCredit?.detail ?? "Error")"
        }
    }
    
    var selectedCurrency: Currency? {
        didSet {
            var container = AttributeContainer()
            container.font = UIFont(name: "GillSans-SemiBold", size: 20)
            currencyButton.configuration?.attributedTitle = AttributedString(selectedCurrency!.retrieveDetailedInformation(), attributes: container)
            currencySymbol = "\(selectedCurrency!.retriviedCurrencySymbol())"
            totalPaymentResultLabel.text = "\(selectedCurrency!.retriviedCurrencySymbol())0"
            locale = selectedCurrency!.locale
            amountTextField.text?.removeAll()
            amountTextField.currency = selectedCurrency
            
            monthlyTextField.text?.removeAll()
            monthlyTextField.currency = selectedCurrency
        }
    }
    
    let saveButton = DTButton(title: "Save", color: .systemPink, systemImageName: "square.and.arrow.down", size: 20)
    let creditNameLabel = DTTitleLabel(textAlignment: .left, fontSize: 25)
    var currencyButton = DTButton(title: "Select Currency", color: .systemRed, size: 20)
    var amountTextField = CurrencyTextField(size: 18)
    var monthlyTextField = CurrencyTextField(size: 18)
    let monthlyInstallmentCountLabel = DTTitleLabel(textAlignment: .left, fontSize: 15, text: "Select Number Of Installments:")
    var monthlyInstallmentCountButton = DTButton(title: "12", color: .systemRed)
    let rateLabel = DTTitleLabel(textAlignment: .left, fontSize: 18, textColor: .systemGray, text: "Interest Rate: ")
    let rateResultLabel = DTTitleLabel(textAlignment: .left, fontSize: 18, textColor: .systemGray, text: "%0.0")
    let totalPaymentLabel = DTTitleLabel(textAlignment: .left, fontSize: 18, textColor: .systemGray, text: "Total Payment:")
    let totalPaymentResultLabel = DTTitleLabel(textAlignment: .left, fontSize: 18, textColor: .systemGray, text: "$0")
    let firstInstallmentLabel = DTTitleLabel(textAlignment: .left, fontSize: 15, text: "Select First Installment:")
    let firstInstallmentDatePicker = UIDatePicker()
    
    let db = Firestore.firestore()
    
    let installmentBottomVc = SelectInstallmentBottomSheetVc()
    var monthCount = 12
    var currencySymbol = "$"
    var firstInstallmentDate = ""
    var interestRateCalculated = ""
    var locale = "en_EN"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        setCurrencyOnStart()
        applyConstraints()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        title = "Add Credit"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        amountTextField.placeholder = "Entry Amount"
        monthlyTextField.placeholder = "Monthly Installment"
        
        firstInstallmentDatePicker.datePickerMode = .date
        firstInstallmentDatePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        
        datePickerValueChanged(sender: firstInstallmentDatePicker)
        
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        currencyButton.addTarget(self, action: #selector(openCurrencyBottomVc), for: .touchUpInside)
        monthlyInstallmentCountButton.addTarget(self, action: #selector(openInstallmentBottomSheet), for: .touchUpInside)
        amountTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        monthlyTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("selectedCount"), object: nil, queue: nil) { [weak self] (notification) in
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
        
        guard let calculatedPayment = totalPaymentResultLabel.text, !calculatedPayment.isEmpty else {
            return
        }
        
        guard let userEmail = Auth.auth().currentUser?.email else {
            return
        }
        
        let creditModel = CreditDetailModel(name: selectedCredit?.name ?? "Error", detail: selectedCredit?.detail ?? "Error", entryDebt: amount, installmentCount: monthCount, paidCount: 0, monthlyInstallment: monthly, firstInstallmentDate: firstInstallmentDate, currentInstallmentDate: firstInstallmentDate, totalDebt: calculatedPayment, interestRate: Double(interestRateCalculated)!, remainingDebt: calculatedPayment, paidDebt: "\(currencySymbol)0", email: userEmail, currency: currencySymbol, locale: locale)
        
        FirestoreManager.shared.createCredit(creditModel: creditModel) { [weak self] result in
            switch result {
            case .success(_):
                let creditsVc = CreditsViewController()
                self?.navigationController?.pushViewController(creditsVc, animated: true)
                
                if let tabBarController = self?.tabBarController {
                    tabBarController.selectedIndex = 1
                }
            case .failure(let failure):
                self?.presentAlert(title: "Warning", message: failure.localizedDescription, buttonTitle: "OK")
            }
        }
        
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
        dismiss(animated: true)
    }
    
    @objc func textFieldDidChange() {
        
        calculateRateAndTotalPayment()
    }
    
    func calculateRateAndTotalPayment() {
        guard let amount = amountTextField.text, !amount.isEmpty else { return }
        guard let monthly = monthlyTextField.text, !monthly.isEmpty else { return }
        
        let result = Currency.convertToDouble(with: locale, for: monthly) * Double(monthCount)
        let calculated = String(format: "%.2f", result)
        totalPaymentResultLabel.text = Currency.currencyInputFormatting(with: locale, for: calculated)
        
        let cleanedAmount = Currency.convertToDouble(with: locale, for: amount)
        
        let interestPrice = result - cleanedAmount
        let interestRate = (interestPrice / cleanedAmount) * Double(monthCount)
        interestRateCalculated = String(format: "%.2f", interestRate)
        rateResultLabel.text = "%\(interestRateCalculated)"
    }
    
    @objc func openCurrencyBottomVc() {
        let rootViewController = SelectCurrencyBottomVc()
        let navController = UINavigationController(rootViewController: rootViewController)
        rootViewController.delegate = self
        self.present(navController, animated: true, completion: nil)
    }
    
    @objc func openInstallmentBottomSheet() {
        if let sheet = installmentBottomVc.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.preferredCornerRadius = 24
        }
        present(installmentBottomVc, animated: true)
    }
    
    private func setCurrencyOnStart() {
        selectedCurrency = Currency(locale: "en_US", amount: 0.0)
    }
    
    private func applyConstraints() {
        firstInstallmentDatePicker.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubviews(saveButton, creditNameLabel, currencyButton, amountTextField, monthlyTextField, monthlyInstallmentCountLabel, monthlyInstallmentCountButton, firstInstallmentLabel, firstInstallmentDatePicker, rateLabel, rateResultLabel, totalPaymentLabel, totalPaymentResultLabel)
        
        let totalWidth = view.frame.width
        let currenyButtonWidth = totalWidth / 2
        
        creditNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        creditNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        creditNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        
        currencyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        currencyButton.topAnchor.constraint(equalTo: creditNameLabel.bottomAnchor, constant: 30).isActive = true
        currencyButton.widthAnchor.constraint(equalToConstant: currenyButtonWidth ).isActive = true
        currencyButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        amountTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        amountTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        amountTextField.topAnchor.constraint(equalTo: currencyButton.bottomAnchor, constant: 10).isActive = true
        amountTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        monthlyTextField.leadingAnchor.constraint(equalTo: amountTextField.leadingAnchor).isActive = true
        monthlyTextField.trailingAnchor.constraint(equalTo: amountTextField.trailingAnchor).isActive = true
        monthlyTextField.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 5).isActive = true
        monthlyTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        monthlyInstallmentCountLabel.topAnchor.constraint(equalTo: monthlyTextField.bottomAnchor, constant: 30).isActive = true
        monthlyInstallmentCountLabel.leadingAnchor.constraint(equalTo: amountTextField.leadingAnchor).isActive = true
        
        monthlyInstallmentCountButton.topAnchor.constraint(equalTo: monthlyTextField.bottomAnchor, constant: 15).isActive = true
        monthlyInstallmentCountButton.leadingAnchor.constraint(equalTo: monthlyInstallmentCountLabel.trailingAnchor, constant: 2).isActive = true
        monthlyInstallmentCountButton.trailingAnchor.constraint(equalTo: amountTextField.trailingAnchor).isActive = true
        monthlyInstallmentCountButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        firstInstallmentLabel.topAnchor.constraint(equalTo: monthlyInstallmentCountButton.bottomAnchor, constant: 17).isActive = true
        firstInstallmentLabel.leadingAnchor.constraint(equalTo: amountTextField.leadingAnchor).isActive = true
        
        firstInstallmentDatePicker.topAnchor.constraint(equalTo: monthlyInstallmentCountButton.bottomAnchor, constant: 10).isActive = true
        firstInstallmentDatePicker.leadingAnchor.constraint(equalTo: firstInstallmentLabel.trailingAnchor, constant: 10).isActive = true
        firstInstallmentDatePicker.trailingAnchor.constraint(equalTo: monthlyInstallmentCountButton.trailingAnchor).isActive = true
        
        rateLabel.topAnchor.constraint(equalTo: firstInstallmentDatePicker.bottomAnchor, constant: 20).isActive = true
        rateLabel.leadingAnchor.constraint(equalTo: amountTextField.leadingAnchor).isActive = true
        
        rateResultLabel.topAnchor.constraint(equalTo: rateLabel.topAnchor).isActive = true
        rateResultLabel.trailingAnchor.constraint(equalTo: monthlyTextField.trailingAnchor, constant: -5).isActive = true
        
        totalPaymentLabel.topAnchor.constraint(equalTo: rateLabel.bottomAnchor, constant: 15).isActive = true
        totalPaymentLabel.leadingAnchor.constraint(equalTo: amountTextField.leadingAnchor).isActive = true
        
        totalPaymentResultLabel.topAnchor.constraint(equalTo: rateLabel.bottomAnchor, constant: 15).isActive = true
        totalPaymentResultLabel.trailingAnchor.constraint(equalTo: rateResultLabel.trailingAnchor).isActive = true
        
        saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5).isActive = true
        saveButton.leadingAnchor.constraint(equalTo: amountTextField.leadingAnchor).isActive = true
        saveButton.trailingAnchor.constraint(equalTo: amountTextField.trailingAnchor).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
}

extension AddCreditViewController: PassCurrencyDelegate {
    func pass(_ currency: Currency) {
        selectedCurrency = currency
    }
}
