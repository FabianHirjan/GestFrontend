//
//  LoginViewModel.swift
//  GestFront
//
//  Created by Fabian Andrei Hirjan on 21.03.2025.
//


// ViewModels/LoginViewModel.swift

// ViewModels/LoginViewModel.swift

import Foundation
import SwiftUI

class LoginViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // setăm true când login-ul reușește,
    // ca să putem naviga spre meniu
    @Published var loginSuccess: Bool = false
    
    func login() {
        errorMessage = nil
        isLoading = true
        
        AuthService.shared.login(username: username, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let (token, role)):
                    // Salvează token, role
                    UserDefaults.standard.set(token, forKey: "jwt_token")
                    UserDefaults.standard.set(role, forKey: "user_role")
                    self?.loginSuccess = true
                    
                case .failure(let error):
                    self?.errorMessage = "Login failed: \(error.localizedDescription)"
                }
            }
        }
    }
}
