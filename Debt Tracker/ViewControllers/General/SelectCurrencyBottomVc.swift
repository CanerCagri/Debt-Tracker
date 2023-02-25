//
//  SelectCurrencyBottomVc.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 13.02.2023.
//

import UIKit

protocol PassCurrencyDelegate: AnyObject {
    func pass(_ currency: Currency)
}

class SelectCurrencyBottomVc: UIViewController {
    
    weak var delegate: PassCurrencyDelegate?
    
    var currencies = [Currency]()
    var filteredCurrencies = [Currency]()
    let searchBar = UISearchBar()
    var isFiltering = false
    var currencyTableView = UITableView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        currencies = Currencies.retrieveAllCurrencies()
        setupSearchTable()
        searchBar.becomeFirstResponder()
        configureTableView()
    }
    
    private func setupSearchTable() {
        self.navigationItem.titleView = searchBar
        searchBar.placeholder = "Search for a Currency"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.barStyle = .default
        searchBar.delegate = self
    }
    
    private func configureTableView() {
        currencyTableView.delegate = self
        currencyTableView.dataSource = self
        currencyTableView.rowHeight = 40
        currencyTableView.layer.cornerRadius = 14
        currencyTableView.frame = view.bounds
        currencyTableView.register(SelectCurrencyCell.self, forCellReuseIdentifier:SelectCurrencyCell.identifier)
        view.addSubview(currencyTableView)
    }
}

extension SelectCurrencyBottomVc: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltering ? filteredCurrencies.count : currencies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectCurrencyCell.identifier, for: indexPath) as! SelectCurrencyCell

        cell.currency = isFiltering ? filteredCurrencies[indexPath.row] : currencies[indexPath.row]

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currency = isFiltering ? filteredCurrencies[indexPath.row] : currencies[indexPath.row]
        delegate?.pass(currency)
        dismiss(animated: true, completion: nil)
    }
}

extension SelectCurrencyBottomVc: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        isFiltering = true
        
        let formattedSearchText = searchText.lowercased()

        filteredCurrencies = currencies.filter({ $0.locale.lowercased().contains(formattedSearchText) || $0.code!.lowercased().contains(formattedSearchText)})
        
        if searchBar.text == "" {
            isFiltering = false
        }
        
        currencyTableView.reloadData()
    }
}
