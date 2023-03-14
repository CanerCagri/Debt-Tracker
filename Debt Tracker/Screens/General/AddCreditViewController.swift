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
    
    let scrollView = UIScrollView()
    let containerView = UIView()
    let saveButton = DTButton(title: "SAVE", color: .systemGray2, systemImageName: "square.and.arrow.down", size: 20)
    let creditNameLabel = DTTitleLabel(textAlignment: .left, fontSize: 25)
    var currencyButton = DTButton(title: "Select Currency", color: .systemRed, size: 20)
    var amountTextField = CurrencyTextField(size: 18)
    var monthlyTextField = CurrencyTextField(size: 18)
    let monthlyInstallmentCountLabel = DTTitleLabel(textAlignment: .left, fontSize: 18, text: "Select Number Of Installments:")
    var monthlyInstallmentCountButton = DTButton(title: "12", color: .systemRed)
    let rateLabel = DTTitleLabel(textAlignment: .left, fontSize: 18, textColor: .systemGray, text: "Interest Rate: ")
    let rateResultLabel = DTTitleLabel(textAlignment: .left, fontSize: 18, textColor: .systemGray, text: "%0.0")
    let totalPaymentLabel = DTTitleLabel(textAlignment: .left, fontSize: 18, textColor: .systemGray, text: "Total Payment:")
    let totalPaymentResultLabel = DTTitleLabel(textAlignment: .left, fontSize: 18, textColor: .systemGray, text: "$0")
    let firstInstallmentLabel = DTTitleLabel(textAlignment: .left, fontSize: 18, text: "Select First Installment:")
    let firstInstallmentDatePicker = UIDatePicker()
    
    let db = Firestore.firestore()
    
    let installmentBottomVc = SelectInstallmentBottomSheetVc()
    var monthCount = 12
    var currencySymbol = "$"
    var firstInstallmentDate = ""
    var interestRateCalculated = ""
    var locale = "en_EN"
    var isKeyboardAppear = false
    var keyboardSaveButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        setCurrencyOnStart()
        applyConstraints()
    }
 
    private func configureViewController() {
        if traitCollection.userInterfaceStyle == .dark {
            view.backgroundColor = UIColor(red: 28/255, green: 30/255, blue: 33/255, alpha: 1.0)
            containerView.backgroundColor = UIColor(red: 28/255, green: 30/255, blue: 33/255, alpha: 1.0)
        } else {
            view.backgroundColor = UIColor.secondarySystemBackground
            containerView.backgroundColor = .secondarySystemBackground
        }
        title = "Add Credit"
        
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
        
        NotificationCenter.default.addObserver(
           self,
           selector: #selector(keyboardWillShow),
           name: UIResponder.keyboardWillShowNotification,
           object: nil
        )
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        containerView.addGestureRecognizer(tap)
    
        keyboardSaveButton = UIButton(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))
        keyboardSaveButton.backgroundColor = UIColor.systemGray2
        keyboardSaveButton.setTitle("SAVE", for: .normal)
        keyboardSaveButton.setTitleColor(UIColor.white, for: .normal)
        keyboardSaveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        amountTextField.inputAccessoryView = keyboardSaveButton
        monthlyTextField.inputAccessoryView = keyboardSaveButton
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if !isKeyboardAppear {
            scrollView.isScrollEnabled = true
            saveButton.isHidden = true
            isKeyboardAppear = true
        }
    }
    
    @objc func dismissKeyboard() {
        if isKeyboardAppear {
            scrollView.isScrollEnabled = false
            let topRect = CGRect(x: 0, y: 0, width: 1, height: 1)
            scrollView.scrollRectToVisible(topRect, animated: true)
            containerView.endEditing(true)
            saveButton.isHidden = false
            isKeyboardAppear = false
        }
    }
    
    @objc func saveButtonTapped() {
        
        guard let amount = amountTextField.text, !amount.isEmpty else {
            presentAlert(title: "Warning", message: "Please Enter Price", buttonTitle: "Ok")
            return
        }
        guard let monthly = monthlyTextField.text, !monthly.isEmpty else {
            presentAlert(title: "Warning", message: "Please Enter Monthly Installment Price", buttonTitle: "Ok")
            return
        }
        
        guard let calculatedPayment = totalPaymentResultLabel.text, !calculatedPayment.isEmpty else {
            return
        }
        
        guard let userEmail = Auth.auth().currentUser?.email else {
            return
        }
        showLoading()
        
        let creditModel = CreditDetailModel(name: selectedCredit?.name ?? "Error", detail: selectedCredit?.detail ?? "Error", entryDebt: amount, installmentCount: monthCount, paidCount: 0, monthlyInstallment: monthly, firstInstallmentDate: firstInstallmentDate, currentInstallmentDate: firstInstallmentDate, totalDebt: calculatedPayment, interestRate: Double(interestRateCalculated)!, remainingDebt: calculatedPayment, paidDebt: "\(currencySymbol)0", email: userEmail, currency: currencySymbol, locale: locale)
        
        FirestoreManager.shared.createCredit(creditModel: creditModel) { [weak self] result in
            switch result {
            case .success(_):
                if let tabBarController = self?.tabBarController {
                    tabBarController.selectedIndex = 1
                }
                self?.dismiss(animated: true)
            case .failure(let failure):
                self?.presentAlert(title: "Warning", message: failure.localizedDescription, buttonTitle: "OK")
            }
            self?.dismissLoading()
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
    
    @objc func textFieldDidChange() { calculateRateAndTotalPayment() }
    
    func calculateRateAndTotalPayment() {
        guard let amount = amountTextField.text, !amount.isEmpty else { return }
        guard let monthly = monthlyTextField.text, !monthly.isEmpty else { return }
        
        if keyboardSaveButton != nil {
            keyboardSaveButton.backgroundColor = .systemPurple
        }
        
        saveButton.configuration?.baseBackgroundColor = .systemPurple
        
        let calculatedPayment = Currency.convertToDouble(with: locale, for: monthly) * Double(monthCount)
        let calculated = String(format: "%.2f", calculatedPayment)
        totalPaymentResultLabel.text = Currency.currencyInputFormatting(with: locale, for: calculated)
        
//        Faiz Oranı = (((Toplam Ödeme / Kredi Tutarı) - 1) / Kredi Vadesi) x 12
//        Faiz Oranı = (((2.295.000 / 1.320.000) - 1) / 60) x 12 = 0,0203 veya %2,03
        
        let cleanedAmount = Currency.convertToDouble(with: locale, for: amount)
        let interestPrice = calculatedPayment - cleanedAmount
        let rate = (((calculatedPayment / cleanedAmount) - 1) / Double(monthCount)) * 12
        print(rate)
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
        containerView.endEditing(true)
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
        
        view.addSubviews(scrollView)
        scrollView.addSubviews(containerView)
        scrollView.isScrollEnabled = false
        scrollView.pinToEdges(view: view)
        
        containerView.pinToEdges(view: scrollView)
        containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
        containerView.addSubviews(saveButton, creditNameLabel, currencyButton, amountTextField, monthlyTextField, monthlyInstallmentCountLabel, monthlyInstallmentCountButton, firstInstallmentLabel, firstInstallmentDatePicker, rateLabel, rateResultLabel, totalPaymentLabel, totalPaymentResultLabel)
        
        let totalWidth = view.frame.width
        let currenyButtonWidth = totalWidth / 2
        
        creditNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10).isActive = true
        creditNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20).isActive = true
        creditNameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20).isActive = true
        
        currencyButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        currencyButton.topAnchor.constraint(equalTo: creditNameLabel.bottomAnchor, constant: 30).isActive = true
        currencyButton.widthAnchor.constraint(equalToConstant: currenyButtonWidth ).isActive = true
        currencyButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        amountTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20).isActive = true
        amountTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20).isActive = true
        amountTextField.topAnchor.constraint(equalTo: currencyButton.bottomAnchor, constant: 10).isActive = true
        amountTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        monthlyTextField.leadingAnchor.constraint(equalTo: amountTextField.leadingAnchor).isActive = true
        monthlyTextField.trailingAnchor.constraint(equalTo: amountTextField.trailingAnchor).isActive = true
        monthlyTextField.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 5).isActive = true
        monthlyTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        monthlyInstallmentCountLabel.topAnchor.constraint(equalTo: monthlyTextField.bottomAnchor, constant: 25).isActive = true
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
        
        let saveButtonTopConstant: CGFloat = DeviceTypes.isiPhoneSE || DeviceTypes.isiPhone8PlusZoomed || DeviceTypes.isiPhone8Standard || DeviceTypes.isiPhone8Zoomed || DeviceTypes.isiPhone8PlusStandard ? 80 : 180
        
        saveButton.topAnchor.constraint(equalTo: totalPaymentResultLabel.bottomAnchor, constant: saveButtonTopConstant).isActive = true
        saveButton.leadingAnchor.constraint(equalTo: amountTextField.leadingAnchor).isActive = true
        saveButton.trailingAnchor.constraint(equalTo: amountTextField.trailingAnchor).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
}

extension AddCreditViewController: PassCurrencyDelegate {
    func pass(_ currency: Currency) {
        selectedCurrency = currency
    }
}
