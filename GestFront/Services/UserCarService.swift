//
//  UserCarService.swift
//  GestFront
//

import Foundation

class UserCarService {
    static let shared = UserCarService()
    private let networkManager = NetworkManager.shared
    
    private init() {}
    
    func fetchUserCar(completion: @escaping (Result<CarDTO, Error>) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "jwt_token"),
              let url = URL(string: "\(Config.baseURL)/users/car") else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "No token or invalid URL"])))
            return
        }
        let request = networkManager.createRequest(url: url, method: "GET", token: token)
        networkManager.performRequest(request, completion: completion)
    }
}

