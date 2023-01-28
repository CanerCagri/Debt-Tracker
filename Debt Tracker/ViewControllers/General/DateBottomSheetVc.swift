//
//  DateBottomSheetVc.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 28.01.2023.
//

import UIKit

class DateBottomSheetVc: UIViewController {
    
    private let datePicker = UIDatePicker()
    
    private let cancelButton = DTButton(title: "Cancel", color: .systemPink, systemImageName: "xmark.circle")
    private let nextButton = DTButton(title: "Next", color: .systemPink, systemImageName: "checkmark.circle")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        addConstraints()
    }
    
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        title = "Choose Entry Date"
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        
        let selectedDate = datePicker.date
        datePicker.datePickerMode = .date
        datePicker.frame = view.bounds
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
    }
    
    @objc func nextButtonTapped() {
        
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
    
    @objc func cancelButtonTapped() {
        NotificationCenter.default.post(Notification(name: Notification.Name("cancelTapped")))
        dismiss(animated: true)
    }
    
    private func addConstraints() {
        view.addSubviews(cancelButton, nextButton, datePicker)
        
        cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5).isActive = true
        cancelButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 5).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        cancelButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5).isActive = true
        nextButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 5).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        nextButton.widthAnchor.constraint(equalToConstant: 100).isActive = true

    }
}
