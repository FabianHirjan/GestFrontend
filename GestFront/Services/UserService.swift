// Services/UserService.swift
import Foundation

class UserService {
    static let shared = UserService()
    private let networkManager = NetworkManager.shared
    
    private init() {}
    
    func fetchLastLocation(completion: @escaping (Result<(latitude: Double, longitude: Double), Error>) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "jwt_token"),
              let url = URL(string: "\(Config.baseURL)/users/last-location") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        let request = networkManager.createRequest(url: url, method: "GET", token: token)
        networkManager.performRequest(request) { (result: Result<[String: Double], Error>) in
            switch result {
            case .success(let json):
                guard let latitude = json["latitude"], let longitude = json["longitude"] else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                    return
                }
                completion(.success((latitude, longitude)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
