//
//  CreditsAddViewController.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 27.01.2023.
//

import UIKit

class CreditsAddViewController: UIViewController {
    
    lazy var contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height - 100)
    
    var containers: [UIView] = []
    
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView(frame: .zero)
        view.backgroundColor = .white
        view.contentSize = contentSize
        view.frame = self.view.bounds
        view.autoresizingMask = .flexibleHeight
        view.bounces = true
        view.showsHorizontalScrollIndicator = true
        return view
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.frame.size = contentSize
        return view
    }()
    
    var nameTextField = DTTextField(placeholder: "Enter a Credit name ", placeHolderSize: 17)
    var entryDebtTextField = DTTextField(placeholder: "Enter a Price", placeHolderSize: 15)
    var paymentDatePicker = UIDatePicker()
    var calculatedCurrentDebtLabel = DTTitleLabel(textAlignment: .left, fontSize: 15)
    var calculatedCurrentDebtTextField = DTTextField(placeholder: "Enter a Calculated Price", placeHolderSize: 15)
    var calculateButton = DTButton(title: "Calculate", color: .systemRed, systemImageName: "gear")
    
    var labels = [DTTitleLabel]()
    var textFields = [DTTextField]()
    var dateLabels = [DTTitleLabel]()
    
    var debtDate = ""
    var currentDebt = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        applyConstraints()
    }
    
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        title = "Add Credit"
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissVC))
        navigationItem.leftBarButtonItem = cancelButton
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(rightBarButtonTapped))
        navigationItem.rightBarButtonItem = saveButton
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        
        paymentDatePicker.datePickerMode = .date
        paymentDatePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        
        calculateButton.addTarget(self, action: #selector(calculateButtonTapped), for: .touchUpInside)
        
        
        datePickerValueChanged(sender: paymentDatePicker)
        
        entryDebtTextField.keyboardType = .numberPad
        calculatedCurrentDebtTextField.keyboardType = .numberPad
        let toolbar = UIToolbar()
        let nextButton = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(moveToNextTextField))
        toolbar.items = [nextButton]
        toolbar.sizeToFit()
        
        nameTextField.inputAccessoryView = toolbar
        
        view.addSubview(scrollView)
        scrollView.backgroundColor = .systemBackground
        scrollView.addSubview(containerView)
        containerView.backgroundColor = .systemBackground
        calculatedCurrentDebtTextField.isHidden = true
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("dismissVc"), object: nil, queue: nil) { [weak self] (notification) in
            self?.dismissVC()
        }
    }
    
    @objc func moveToNextTextField() {
        entryDebtTextField.becomeFirstResponder()
    }
    
    @objc func datePickerValueChanged(sender: UIDatePicker){
        let selectedDate = sender.date
        let calendar = Calendar.current
        let day = calendar.component(.day, from: selectedDate)
        let month = calendar.component(.month, from: selectedDate)
        let year = calendar.component(.year, from: selectedDate)
        
        let calculatedDay = String(format: "%02d", day)
        let calculatedMonth = String(format: "%02d", month)
        
        debtDate = "\(calculatedDay).\(calculatedMonth).\(year)"
        print(debtDate)
        
        
        if !dateLabels.isEmpty {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            
            let entryDate = formatter.date(from: debtDate)!
            
            for i in 1...12 {
                
                let newDate = calendar.date(byAdding: .day, value: 30 * i, to: entryDate)!
                let newDateString = formatter.string(from: newDate)
                
                dateLabels[i - 1].text = newDateString
                
            }
        }
    }
    
    @objc func calculateButtonTapped() {
        
        guard let entryDebt = entryDebtTextField.text, !entryDebt.isEmpty else {
            presentAlert(title: "Warning", message: "Please enter a Price", buttonTitle: "Ok")
            return
        }
        
        labels.removeAll()
        textFields.removeAll()
        dateLabels.removeAll()
        view.endEditing(true)
        navigationItem.rightBarButtonItem?.isEnabled = true
        
        let labelText = entryDebt
        let number = Int(labelText)!
        currentDebt = number + number / 100 * 5
        let monthlyDebt = Double(currentDebt) / 12
        let roundedMonthlyDebt = String(format: "%.2f", monthlyDebt)
        
        calculatedCurrentDebtLabel.text = "New Calculated Debt:"
        calculatedCurrentDebtTextField.isHidden = false
        calculatedCurrentDebtTextField.text = String(currentDebt)
        
        
        for i in 0..<12 {
            let label = DTTitleLabel(textAlignment: .left, fontSize: 10)
            label.text = "Installment for the \(i.ordinal()) month:"
            label.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(label)
            labels.append(label)
            
            let textField = DTTextField(placeholder: "Enter Monthly Installment", placeHolderSize: 10)
            textField.borderStyle = .roundedRect
            textField.translatesAutoresizingMaskIntoConstraints = false
            if i != 0 { // only the first text field is enabled
                textField.isEnabled = false
                textField.placeholder = ""
            }
            containerView.addSubview(textField)
            textFields.append(textField)
            textFields[i].text = String(roundedMonthlyDebt)
            textFields[0].addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
            
        }
        
        for (index, label) in labels.enumerated() {
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
                label.widthAnchor.constraint(equalToConstant: 120),
                label.heightAnchor.constraint(equalToConstant: 20)
            ])
            if index == 0 {
                NSLayoutConstraint.activate([
                    label.topAnchor.constraint(equalTo: calculateButton.bottomAnchor, constant: 20)
                ])
            } else {
                NSLayoutConstraint.activate([
                    label.topAnchor.constraint(equalTo: labels[index-1].bottomAnchor, constant: 20)
                ])
            }
            
            NSLayoutConstraint.activate([
                textFields[index].leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 5),
                textFields[index].widthAnchor.constraint(equalToConstant: 130),
                textFields[index].topAnchor.constraint(equalTo: label.topAnchor),
                textFields[index].heightAnchor.constraint(equalTo: label.heightAnchor)
            ])
            
        }
        
        
        for i in 0...11 {
            let dateLabel = DTTitleLabel(textAlignment: .center, fontSize: 10)
            dateLabel.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(dateLabel)
            // Position the label to the right of the text field, and align their vertical center
            dateLabel.centerYAnchor.constraint(equalTo: textFields[i].centerYAnchor).isActive = true
            dateLabel.leadingAnchor.constraint(equalTo: textFields[i].trailingAnchor, constant: 20).isActive = true
            dateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20).isActive = true
            // Add the label to the array
            dateLabels.append(dateLabel)
            
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        
        let entryDate = formatter.date(from: debtDate)!
        
        
        let calendar = Calendar.current
        
        for i in 1...12 {
            
            let newDate = calendar.date(byAdding: .day, value: 30 * i, to: entryDate)!
            let newDateString = formatter.string(from: newDate)
            
            dateLabels[i - 1].text = newDateString
            
        }
        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        // update the text of all other text fields to match the text of the first text field
        for i in 1..<textFields.count {
            textFields[i].text = textField.text
        }
    }
    
    @objc func rightBarButtonTapped() {
        
        guard let name = nameTextField.text, !name.isEmpty else {
            presentAlert(title: "Warning", message: "Please enter a Credit name", buttonTitle: "Ok")
            return
        }
        
        guard let entryDebt = entryDebtTextField.text, !entryDebt.isEmpty else {
            presentAlert(title: "Warning", message: "Please enter a Price", buttonTitle: "Ok")
            return
        }
        
        guard let monthlyDebt = textFields[0].text, !monthlyDebt.isEmpty else {
            presentAlert(title: "Warning", message: "Please enter a Monthly Installment", buttonTitle: "Ok")
            return
        }
        
        guard let calculatedDebt = calculatedCurrentDebtTextField.text, !calculatedDebt.isEmpty else {
            presentAlert(title: "Warning", message: "Please enter a Calculated Price", buttonTitle: "Ok")
            return
        }
        
        let currentDebtTextFieldText = calculatedCurrentDebtTextField.text
        
        let viewModel = CreditModel(id: UUID().uuidString, name: name, entryDebt: Int(entryDebt)!, paidCount: 0, monthlyDebt: Double(monthlyDebt)!, paymentDate: dateLabels[0].text!, currentDebt: Int(currentDebtTextFieldText!)!, remainingDebt: Double(currentDebtTextFieldText!)!, paidDebt: 0.0)
        
        PersistenceManager.shared.downloadWithModel(model: viewModel) { result in
            switch result {
            case .success():
                NotificationCenter.default.post(Notification(name: Notification.Name("saveTapped")))
                let alertController = UIAlertController(title: "Credit Succesfully Created", message: nil, preferredStyle: .alert)
                
                let deleteButton = UIAlertAction(title: "OK", style: .default) { _ in
                    self.dismissVC()
                }
                
                alertController.addAction(deleteButton)
                self.present(alertController, animated: true)
                
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }
    
    @objc func dismissVC() {
        dismiss(animated: true)
    }
    
    private func applyConstraints() {
        containers = [nameTextField, entryDebtTextField, paymentDatePicker, calculatedCurrentDebtLabel, calculatedCurrentDebtTextField, calculateButton]
        for containerViews in containers {
            containerView.addSubview(containerViews)
            containerViews.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let totalWidth = view.frame.width
        let textFieldWidth = totalWidth / 2
        let buttonWidth = totalWidth / 3
        
        nameTextField.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor).isActive = true
        nameTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20).isActive = true
        nameTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20).isActive = true
        nameTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        entryDebtTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 30).isActive = true
        entryDebtTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20).isActive = true
        entryDebtTextField.widthAnchor.constraint(equalToConstant: textFieldWidth - 20).isActive = true
        entryDebtTextField.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        paymentDatePicker.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 30).isActive = true
        paymentDatePicker.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20).isActive = true
        
        calculatedCurrentDebtLabel.topAnchor.constraint(equalTo: entryDebtTextField.bottomAnchor, constant: 20).isActive = true
        calculatedCurrentDebtLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20).isActive = true
        
        
        calculatedCurrentDebtTextField.topAnchor.constraint(equalTo: entryDebtTextField.bottomAnchor , constant: 10).isActive = true
        calculatedCurrentDebtTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        calculatedCurrentDebtTextField.leadingAnchor.constraint(equalTo: calculatedCurrentDebtLabel.trailingAnchor, constant: 10).isActive = true
        calculatedCurrentDebtTextField.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        calculateButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        calculateButton.topAnchor.constraint(equalTo: calculatedCurrentDebtTextField.bottomAnchor, constant: 30).isActive = true
        calculateButton.heightAnchor.constraint(equalToConstant: 70).isActive = true
        calculateButton.widthAnchor.constraint(equalToConstant: buttonWidth + 30).isActive = true
    }
}
