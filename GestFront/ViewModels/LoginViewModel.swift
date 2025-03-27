// ViewModels/LoginViewModel.swift
import SwiftUI

class LoginViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false
    
    func login() {
        isLoading = true
        errorMessage = nil
        AuthService.shared.login(username: username, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success:
                    self?.isAuthenticated = true
                case .failure(let error):
                    self?.errorMessage = "Login failed: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func checkExistingSession() {
        isLoading = true
        AuthService.shared.validateToken { [weak self] isValid in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.isAuthenticated = isValid
            }
        }
    }
}
