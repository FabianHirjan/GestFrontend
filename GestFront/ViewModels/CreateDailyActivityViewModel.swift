//
//  CreateDailyActivityView.swift
//  GestFront
//
//  Created by Fabian Andrei Hirjan on 21.03.2025.
//

import SwiftUI

class CreateDailyActivityViewModel: ObservableObject {
    @Published var descriptionText: String = ""
    @Published var kilometers: String = ""
    @Published var fuelConsumption: String = ""
    @Published var date: Date = Date()
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var creationSuccess: Bool = false

    // Adaugă constructorul nou aici
    init(description: String, kilometers: Int, fuelConsumption: Double) {
        self.descriptionText = description
        self.kilometers = "\(kilometers)"
        self.fuelConsumption = "\(fuelConsumption)"
    }

    
    func createActivity() {
        isLoading = true
        errorMessage = nil
        
        guard let km = Int(kilometers) else {
            self.errorMessage = "Kilometers must be an integer!"
            self.isLoading = false
            return
        }
        
        guard let fuel = Double(fuelConsumption) else {
            self.errorMessage = "Fuel consumption must be a valid number!"
            self.isLoading = false
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        
        DailyActivityService.shared.createDailyActivity(
            description: descriptionText,
            kilometers: km,
            fuelConsumption: fuel,
            date: dateString
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(_):
                    self?.creationSuccess = true
                case .failure(let error):
                    self?.errorMessage = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
}
