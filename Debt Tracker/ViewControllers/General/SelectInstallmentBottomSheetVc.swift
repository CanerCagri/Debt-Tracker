//
//  CreditsBottomSheetVc.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 2.02.2023.
//

import UIKit

class SelectInstallmentBottomSheetVc: UIViewController {
    
    var pickerView = UIPickerView()
    let numbers = [3, 6, 9, 12, 18, 24, 30, 36, 42, 48, 54, 60, 66, 72, 78, 84, 90, 96, 102, 108, 114, 120, 126, 132, 138, 144, 150, 156, 162, 168, 174, 180, 186, 192, 198, 204, 210, 216, 222, 228, 234, 240]
    
    private let nextButton = DTButton(title: "Next", color: .systemPink, systemImageName: "checkmark.circle", size: 20)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        
        configurePickerView()
        addConstraints()
    }
    
    func configurePickerView() {
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 500)
        view.addSubview(pickerView)
        
        let defaultSelection = 3
        pickerView.selectRow(defaultSelection, inComponent: 0, animated: false)
    }
    
    @objc func nextButtonTapped() {
        let selectedRow = pickerView.selectedRow(inComponent: 0)
        let selectedValue = numbers[selectedRow]
        
        let userInfo = ["selectedCount": selectedValue]
        NotificationCenter.default.post(Notification(name: Notification.Name("selectedCount"), userInfo: userInfo))
        dismiss(animated: true)
    }
    
    @objc func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    private func addConstraints() {
        view.addSubviews(nextButton)

        nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5).isActive = true
        nextButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 5).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        nextButton.widthAnchor.constraint(equalToConstant: 120).isActive = true
    }
}

extension SelectInstallmentBottomSheetVc: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
          return 1
      }
      
      func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
          return numbers.count
      }
      
      func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
          return "\(numbers[row])"
      }
    
}
