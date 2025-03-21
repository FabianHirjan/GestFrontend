//
//  DailyActivityService.swift
//  GestFront
//
//  Created by Fabian Andrei Hirjan on 21.03.2025.
//


// Services/DailyActivityService.swift

import Foundation

class DailyActivityService {
    static let shared = DailyActivityService()
    
    private init() {}
    
    // 1) Obține lista tuturor Daily Activities
    func fetchDailyActivities(completion: @escaping (Result<[DailyActivityDTO], Error>) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "jwt_token") else {
            let error = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "No token"])
            completion(.failure(error))
            return
        }
        
        guard let url = URL(string: "\(Config.baseURL)/dailyactivities") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let data = data, let httpResponse = response as? HTTPURLResponse {
                guard (200...299).contains(httpResponse.statusCode) else {
                    let statusError = NSError(domain: "", code: httpResponse.statusCode, userInfo: nil)
                    completion(.failure(statusError))
                    return
                }
                do {
                    let activities = try JSONDecoder().decode([DailyActivityDTO].self, from: data)
                    completion(.success(activities))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    // 2) Creează o nouă Daily Activity
    func createDailyActivity(description: String,
                             kilometers: Int,
                             fuelConsumption: Double,
                             date: String,
                             completion: @escaping (Result<DailyActivityDTO, Error>) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "jwt_token") else {
            let error = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "No token"])
            completion(.failure(error))
            return
        }
        
        guard let url = URL(string: "\(Config.baseURL)/dailyactivities") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Body JSON
        let body: [String: Any] = [
            "description": description,
            "kilometers": kilometers,
            "fuelConsumption": fuelConsumption,
            "date": date
            // "approved": false  // dacă e setat implicit de server, e OK să nu-l trimiți
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let data = data, let httpResponse = response as? HTTPURLResponse {
                guard (200...299).contains(httpResponse.statusCode) else {
                    let statusError = NSError(domain: "", code: httpResponse.statusCode, userInfo: nil)
                    completion(.failure(statusError))
                    return
                }
                do {
                    let activity = try JSONDecoder().decode(DailyActivityDTO.self, from: data)
                    completion(.success(activity))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
