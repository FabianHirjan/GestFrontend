//
//  MyCarViewModel.swift
//  GestFront
//

import Foundation
// MyCarViewModel
class MyCarViewModel: ObservableObject {
    @Published var car: CarDTO?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func fetchCar() {
        isLoading = true
        errorMessage = nil
        
        UserCarService.shared.fetchUserCar { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                switch result {
                case .success(let car):
                    self.car = car
                case .failure(let error):
                    self.errorMessage = "Failed to load car: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func formattedDate(_ date: String?) -> String {
        guard let dateStr = date else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"
        if let date = formatter.date(from: dateStr) {
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
        return dateStr
    }
}
