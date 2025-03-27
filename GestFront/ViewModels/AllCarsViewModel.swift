//
//  AllCarsViewModel.swift
//  GestFront
//

import Foundation

class AllCarsViewModel: ObservableObject {
    @Published var cars: [CarDTO] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    func fetchCars() {
        isLoading = true
        errorMessage = nil
        
        CarService.shared.fetchAllCars { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                switch result {
                case .success(let cars):
                    self.cars = cars
                case .failure(let error):
                    self.errorMessage = "Failed to load cars: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func assignCar(carId: Int64, userId: Int64) {
        CarService.shared.assignCar(carId: carId, userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success:
                    self.fetchCars()
                case .failure(let error):
                    self.errorMessage = "Failed to assign car: \(error.localizedDescription)"
                }
            }
        }
    }
}
