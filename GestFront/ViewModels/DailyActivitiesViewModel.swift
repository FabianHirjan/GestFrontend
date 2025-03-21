//
//  DailyActivitiesViewModel.swift
//  GestFront
//
//  Created by Fabian Andrei Hirjan on 21.03.2025.
//


// ViewModels/DailyActivitiesViewModel.swift

import Foundation

class DailyActivitiesViewModel: ObservableObject {
    @Published var activities: [DailyActivityDTO] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    func fetchActivities() {
        isLoading = true
        errorMessage = nil

        DailyActivityService.shared.fetchDailyActivities { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let list):
                    self?.activities = list.sorted(by: { $0.date < $1.date })
                case .failure(let error):
                    self?.errorMessage = "Failed to load activities: \(error.localizedDescription)"
                }
            }
        }
    }


    // Funcție suplimentară pentru a obține datele pentru grafic
    var fuelConsumptionData: [(date: String, consumption: Double)] {
        activities.map { ($0.date, $0.fuelConsumption) }
    }
}
