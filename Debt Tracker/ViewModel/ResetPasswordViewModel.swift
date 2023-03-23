//
//  ResetPasswordViewModel.swift
//  Debt Tracker
//
//  Created by Caner Çağrı on 23.03.2023.
//

import Foundation


class ResetPasswordViewModel: ResetPasswordViewModelProtocol {
    
    var delegate: ResetPasswordViewModelDelegate?
    
    func resetPassword(email: String) {
        AuthManager.shared.resetPassword(email: email) { [weak self] result in
            self?.delegate?.handleViewModelOutput(result)
        }
    }
}
