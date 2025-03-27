//
//  DailyActivitiesViewModel.swift
//  GestFront
//

import Foundation

class DailyActivitiesViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var activities: [DailyActivityDTO] = []
    @Published var fuelConsumptionData: [(date: String, consumption: Double)] = []
    
    func fetchActivities() {
        isLoading = true
        errorMessage = nil
        
        DailyActivityService.shared.fetchActivities { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                switch result {
                case .success(let activities):
                    self.activities = activities
                    self.fuelConsumptionData = activities.map { (date: $0.date, consumption: $0.fuelConsumption ?? 0.0) }
                case .failure(let error):
                    self.errorMessage = "Failed to load activities: \(error.localizedDescription)"
                }
            }
        }
    }
}
