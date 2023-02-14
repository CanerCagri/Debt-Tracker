//
//  SelectCurrencyBottomVc.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 13.02.2023.
//

import UIKit

class SelectCurrencyBottomVc: UIViewController {
    
    let currencies = CurrenyData.currencyData
    
    var currencyTableView = UITableView()
    var selectedRow: String?
    var selectedISO: String?
    
    private let nextButton = DTButton(title: "Next", color: .systemPink, systemImageName: "checkmark.circle")
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        
        configureTableView()
        applyConstraints()
    }
    
    private func configureTableView() {
        currencyTableView.delegate = self
        currencyTableView.dataSource = self
        currencyTableView.rowHeight = 40
        currencyTableView.layer.cornerRadius = 14
        currencyTableView.translatesAutoresizingMaskIntoConstraints = false
        currencyTableView.register(CurrencyTableViewCell.self, forCellReuseIdentifier:CurrencyTableViewCell.identifier)
    }
    
    @objc func nextButtonTapped() {
        if selectedRow != nil && selectedISO != nil {
            let userInfo = ["selectedCurrency": selectedRow, "selectedISO": selectedISO]
            NotificationCenter.default.post(Notification(name: Notification.Name("selectedCurrency"), userInfo: userInfo as [AnyHashable : Any]))
            dismiss(animated: true)
        } else {
            presentAlert(title: "Warning", message: "Please select a Currency", buttonTitle: "OK")
        }

    }
    
    @objc func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    private func applyConstraints() {
        view.addSubviews(currencyTableView, nextButton)
    
        nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5).isActive = true
        nextButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 5).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        nextButton.widthAnchor.constraint(equalToConstant: 120).isActive = true
        
        currencyTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
        currencyTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        currencyTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        currencyTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
    }
}

extension SelectCurrencyBottomVc: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CurrencyTableViewCell.identifier, for: indexPath) as? CurrencyTableViewCell
        cell?.currencyLabel.text = "\(currencies[indexPath.row].name) - \(currencies[indexPath.row].symbol) - (\(currencies[indexPath.row].ISO)) "
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = "\(currencies[indexPath.row].symbol) - \(currencies[indexPath.row].ISO)"
        selectedISO = currencies[indexPath.row].ISO
    }
}
