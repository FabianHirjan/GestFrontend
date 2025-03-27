//
//  DutyTrackingService.swift
//  GestFront
//

import Foundation
import CoreLocation

class DutyTrackingService {
    static let shared = DutyTrackingService()
    
    private init() {}
    
    func sendLiveLocation(location: CLLocation, averageSpeed: Double, userId: String) {
        guard let url = URL(string: "\(Config.baseURL)/users/location") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(UserDefaults.standard.string(forKey: "jwt_token") ?? "")", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "userId": userId,
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "speed": averageSpeed,
            "timestamp": ISO8601DateFormatter().string(from: location.timestamp)
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("Error serializing live location: \(error)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print("Error sending live location: \(error)")
                return
            }
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("Live location sent for user \(userId)")
            }
        }.resume()
    }
    
    func sendDutySummary(description: String, kilometers: Double, averageSpeed: Double, locations: [CLLocation], completion: @escaping (Result<Int, Error>) -> Void) {
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
            "averageSpeed": averageSpeed,
            "fuelConsumption": 0.0, // Placeholder
            "date": ISO8601DateFormatter().string(from: Date())
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
