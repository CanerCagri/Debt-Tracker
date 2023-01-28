//
//  CreditsAddViewController.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 27.01.2023.
//

import UIKit

class CreditsAddViewController: UIViewController {
    
    var nameTextField = DTTextField(placeholder: "Enter a Credit name ", placeHolderSize: 17)
    var entryDebt = DTTextField(placeholder: "Enter a Price", placeHolderSize: 15)
    var paymentDate = UIDatePicker()
    var calculateButton = DTButton(title: "Calculate", color: .systemRed, systemImageName: "gear")
    
    
    
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
        
        let selectedDate = paymentDate.date
        paymentDate.datePickerMode = .date
        paymentDate.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        
        calculateButton.addTarget(self, action: #selector(calculateButtonTapped), for: .touchUpInside)
    }
    
    @objc func datePickerValueChanged(sender: UIDatePicker){
        let selectedDate = sender.date
        let calendar = Calendar.current
        let day = calendar.component(.day, from: selectedDate)
        let month = calendar.component(.month, from: selectedDate)
        let year = calendar.component(.year, from: selectedDate)
        print("Day: \(day)")
        print("Month: \(month)")
        print("Year: \(year)")
    }
    
    @objc func calculateButtonTapped() {
        
    }
    
    @objc func rightBarButtonTapped() {
        print("rightbar tapped")
    }
    
    @objc func dismissVC() {
        dismiss(animated: true)
    }
    
    private func applyConstraints() {
        view.addSubviews(nameTextField, entryDebt, paymentDate, calculateButton)
        
        let totalWidth = view.frame.width
        let textFieldWidth = totalWidth / 2
        let buttonWidth = totalWidth / 3
        
        paymentDate.translatesAutoresizingMaskIntoConstraints = false
        
        nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        nameTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        entryDebt.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 30).isActive = true
        entryDebt.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        entryDebt.widthAnchor.constraint(equalToConstant: textFieldWidth - 20).isActive = true
        entryDebt.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        paymentDate.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 30).isActive = true
        paymentDate.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true

        calculateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        calculateButton.topAnchor.constraint(equalTo: entryDebt.bottomAnchor, constant: 40).isActive = true
        calculateButton.heightAnchor.constraint(equalToConstant: 70).isActive = true
        calculateButton.widthAnchor.constraint(equalToConstant: buttonWidth + 30).isActive = true
        
    }
}
