// ViewModels/MenuViewModel.swift
import Foundation

class MenuViewModel: ObservableObject {
    @Published var is_logged_in = true
    
    func logout() {
        AuthService.shared.logout()
        is_logged_in = false
    }
}
