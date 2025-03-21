//
//  MyCarViewModel.swift
//  GestFront
//
//  Created by Fabian Andrei Hirjan on 21.03.2025.
//


// ViewModels/MyCarViewModel.swift

import Foundation

class MyCarViewModel: ObservableObject {
    @Published var car: CarDTO?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    func fetchCar() {
        isLoading = true
        errorMessage = nil
        
        UserCarService.shared.fetchUserCar { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let carDTO):
                    self?.car = carDTO
                case .failure(let error):
                    self?.errorMessage = "Failed to load car: \(error.localizedDescription)"
                }
            }
        }
    }

    // Formatare simplificată a datei
    func formattedDate(_ dateString: String?) -> String {
        guard let dateString = dateString else { return "N/A" }
        let formatterIn = DateFormatter()
        formatterIn.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"
        
        if let date = formatterIn.date(from: dateString) {
            let formatterOut = DateFormatter()
            formatterOut.dateFormat = "yyyy-MM-dd"
            return formatterOut.string(from: date)
        } else {
            return "N/A"
        }
    }
}

extension MyCarViewModel {
    
    // Verifică expirarea asigurării
    var isInsuranceExpired: Bool {
        guard let dateString = car?.insuranceExpiration else { return false }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"
        guard let date = formatter.date(from: dateString) else { return false }
        return date < Date()
    }
    
    // Verifică dacă ultima inspecție a fost acum mai mult de un an
    var isInspectionExpired: Bool {
        guard let dateString = car?.lastInspection else { return false }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"
        guard let date = formatter.date(from: dateString) else { return false }
        return Calendar.current.date(byAdding: .year, value: 1, to: date)! < Date()
    }
}


