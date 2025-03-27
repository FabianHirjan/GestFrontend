//
//  DailyActivityService.swift
//  GestFront
//

import Foundation

class DailyActivityService {
    static let shared = DailyActivityService()
    
    private init() {}
    
    func fetchActivities(completion: @escaping (Result<[DailyActivityDTO], Error>) -> Void) {
        guard let url = URL(string: "\(Config.baseURL)/dailyactivities") else {
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
                  let activities = try? JSONDecoder().decode([DailyActivityDTO].self, from: data) else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }
            completion(.success(activities))
        }.resume()
    }
    
    func createActivity(description: String, kilometers: Double, date: Date, completion: @escaping (Result<Int, Error>) -> Void) {
        guard let url = URL(string: "\(Config.baseURL)/dailyactivities") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(UserDefaults.standard.string(forKey: "jwt_token") ?? "")", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "description": description,
            "kilometers": kilometers,
            "date": ISO8601DateFormatter().string(from: date),
            "fuelConsumption": 0.0
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode),
                  let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let id = json["id"] as? Int else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }
            completion(.success(id))
        }.resume()
    }
}

