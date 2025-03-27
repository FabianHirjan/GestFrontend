//
//  CarMaintenanceService.swift
//  GestFront
//
//  Created by Fabian Andrei Hirjan on 27.03.2025.
//


import Foundation

class CarMaintenanceService {
    static let shared = CarMaintenanceService()
    private init() {}
    
    // Construim URL-ul de bază folosind Config.baseURL
    private let baseMaintenanceURL = "\(Config.baseURL)/car/maintenance"
    
    func markInsurance(carId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseMaintenanceURL)/\(carId)/insurance") else { return }
        let request = NetworkManager.shared.createRequest(url: url, method: "POST")
        NetworkManager.shared.performVoidRequest(request, completion: completion)
    }
    
    // Marchează schimbul de ulei cu data de azi
    func markOilChange(carId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseMaintenanceURL)/\(carId)/oil-change") else { return }
        let request = NetworkManager.shared.createRequest(url: url, method: "POST")
        NetworkManager.shared.performVoidRequest(request, completion: completion)
    }
    
    // Marchează schimbul de anvelope cu data de azi
    func markTireChange(carId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseMaintenanceURL)/\(carId)/tire-change") else { return }
        let request = NetworkManager.shared.createRequest(url: url, method: "POST")
        NetworkManager.shared.performVoidRequest(request, completion: completion)
    }
    
    // Marchează întreținerea (inspecția) cu data de azi
    func markMaintenance(carId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseMaintenanceURL)/\(carId)/maintenance") else { return }
        let request = NetworkManager.shared.createRequest(url: url, method: "POST")
        NetworkManager.shared.performVoidRequest(request, completion: completion)
    }
}
