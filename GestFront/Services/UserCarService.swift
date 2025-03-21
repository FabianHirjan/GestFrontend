//
//  UserCarService.swift
//  GestFront
//
//  Created by Fabian Andrei Hirjan on 21.03.2025.
//


// Services/UserCarService.swift

import Foundation

class UserCarService {
    static let shared = UserCarService()
    
    private init() {}
    
    func fetchUserCar(completion: @escaping (Result<CarDTO, Error>) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "jwt_token") else {
            // N-ar trebui să ajungem aici dacă ești logat
            let noTokenError = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "No token found"])
            completion(.failure(noTokenError))
            return
        }
        guard let url = URL(string: "\(Config.baseURL)/user/car") else {
            // Sau URL-ul tău real
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // Adăugăm header-ul de autorizare
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let data = data,
               let httpResponse = response as? HTTPURLResponse {
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    let statusError = NSError(domain: "", code: httpResponse.statusCode, userInfo: nil)
                    completion(.failure(statusError))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    // dacă datele de tip "yyyy-MM-dd HH:mm:ss" sunt de tip string, 
                    // nu e nevoie de alt dateDecodingStrategy
                    let carDTO = try decoder.decode(CarDTO.self, from: data)
                    completion(.success(carDTO))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
