//
//  AutoDailyActivityViewModel.swift
//  GestFront
//
//  Created by Fabian Andrei Hirjan on 21.03.2025.
//


import SwiftUI

class AutoDailyActivityViewModel: ObservableObject {
    @Published var descriptionText: String
    @Published var kilometers: String = ""
    @Published var fuelConsumption: String = ""
    @Published var date: Date = Date()
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var creationSuccess: Bool = false

    init(routeDescription: String) {
        self.descriptionText = routeDescription
    }

    func createActivity() {
        isLoading = true
        errorMessage = nil

        guard let km = Int(kilometers) else {
            errorMessage = "Kilometers must be integer"
            isLoading = false
            return
        }

        guard let fuel = Double(fuelConsumption) else {
            errorMessage = "Invalid fuel consumption"
            isLoading = false
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
