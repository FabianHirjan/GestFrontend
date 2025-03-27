//
//  UserService.swift
//  GestFront
//

import Foundation

class UserService {
    static let shared = UserService()
    
    private init() {}
    
    func fetchLastLocation(completion: @escaping (Result<(latitude: Double, longitude: Double), Error>) -> Void) {
        guard let url = URL(string: "\(Config.baseURL)/users/last-location") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(UserDefaults.standard.string(forKey: "jwt_token") ?? "")", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []),
                  let dict = json as? [String: Any],
                  let latitude = dict["latitude"] as? Double,
                  let longitude = dict["longitude"] as? Double else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }
            completion(.success((latitude, longitude)))
        }.resume()
    }
}
