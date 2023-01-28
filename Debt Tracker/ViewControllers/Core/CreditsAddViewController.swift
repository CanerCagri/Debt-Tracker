//
//  CreditsAddViewController.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 27.01.2023.
//

import UIKit

class CreditsAddViewController: UIViewController {
    
    lazy var contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height - 200)
    
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
    var entryDebt = DTTextField(placeholder: "Enter a Price", placeHolderSize: 15)
    var paymentDatePicker = UIDatePicker()
    var calculatedCurrentDebt = DTTitleLabel(textAlignment: .left, fontSize: 20)
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
        
        paymentDatePicker.datePickerMode = .date
        paymentDatePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        
        calculateButton.addTarget(self, action: #selector(calculateButtonTapped), for: .touchUpInside)
        
 
        datePickerValueChanged(sender: paymentDatePicker)
        
        
        view.addSubview(scrollView)
        scrollView.backgroundColor = .systemBackground
        scrollView.addSubview(containerView)
        containerView.backgroundColor = .systemBackground
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("dismissVc"), object: nil, queue: nil) { [weak self] (notification) in
            self?.dismissVC()
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
        
        debtDate = "\(calculatedDay).\(calculatedMonth).\(year)"
        print(debtDate)
    }
    
    @objc func calculateButtonTapped() {
    
        guard let entryDebt = entryDebt.text, !entryDebt.isEmpty else {
//            presentAlert(title: "Warning", message: "Please enter a Pomodoro name", buttonTitle: "Ok")
            return
        }
        
        let labelText = entryDebt
        let number = Int(labelText)!
        currentDebt = number + number / 100 * 5
        let monthlyDebt = Double(currentDebt) / 12
        let roundedMonthlyDebt = String(format: "%.2f", monthlyDebt)
        
        calculatedCurrentDebt.text = "12 Month Installment Calculated Debt: \(String(currentDebt))"
        
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
        
        for i in 0..<12 {
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
        
        //Date labels texts
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let date = dateFormatter.date(from: debtDate)!

        let calendar = Calendar.current
        var next12Months = date
        for i in 0...11 {
            next12Months = calendar.date(byAdding: .month, value: 1, to: next12Months)!
            let next12MonthsString = dateFormatter.string(from: next12Months)
            dateLabels[i].text = next12MonthsString
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
//            presentAlert(title: "Warning", message: "Please enter a Pomodoro name", buttonTitle: "Ok")
            return
        }
        
        guard let entryDebt = entryDebt.text, !entryDebt.isEmpty else {
//            presentAlert(title: "Warning", message: "Please enter a Pomodoro name", buttonTitle: "Ok")
            return
        }
        
        guard let monthlyDebt = textFields[0].text, !monthlyDebt.isEmpty else {
//            presentAlert(title: "Warning", message: "Please enter a Pomodoro name", buttonTitle: "Ok")
            return
        }
        
        let viewModel = CreditModel(name: name, entryDebt: Int(entryDebt)!, paidCount: 0, monthlyDebt: Double(monthlyDebt)!, paymentDate: debtDate, currentDebt: currentDebt, remainingDebt: Double(currentDebt))
        
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
        containers = [nameTextField, entryDebt, paymentDatePicker, calculatedCurrentDebt, calculateButton]
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
        
        entryDebt.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 30).isActive = true
        entryDebt.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20).isActive = true
        entryDebt.widthAnchor.constraint(equalToConstant: textFieldWidth - 20).isActive = true
        entryDebt.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        paymentDatePicker.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 30).isActive = true
        paymentDatePicker.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20).isActive = true
        
        calculatedCurrentDebt.topAnchor.constraint(equalTo: entryDebt.bottomAnchor, constant: 10).isActive = true
        calculatedCurrentDebt.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20).isActive = true
        calculatedCurrentDebt.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20).isActive = true

        calculateButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        calculateButton.topAnchor.constraint(equalTo: calculatedCurrentDebt.bottomAnchor, constant: 30).isActive = true
        calculateButton.heightAnchor.constraint(equalToConstant: 70).isActive = true
        calculateButton.widthAnchor.constraint(equalToConstant: buttonWidth + 30).isActive = true
        
    }
}
