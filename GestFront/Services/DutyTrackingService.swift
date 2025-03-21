//
//  DutyTrackingService.swift
//  GestFront
//
//  Created by Fabian Andrei Hirjan on 21.03.2025.
//

import Foundation
import CoreLocation

class DutyTrackingService {
    
    static let shared = DutyTrackingService()
    
    private init() {}
    
    private let liveLocationURL = "\(Config.baseURL)/live-location"
    private let dutySummaryURL = "\(Config.baseURL)/duty-summary"
    
    func sendLiveLocation(location: CLLocation, averageSpeed: Double?, completion: ((Bool) -> Void)? = nil) {
        
        guard let url = URL(string: liveLocationURL) else {
            completion?(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(UserDefaults.standard.string(forKey: "jwt_token") ?? "")", forHTTPHeaderField: "Authorization")

        let payload: [String: Any] = [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "speed": location.speed >= 0 ? location.speed * 3.6 : 0, // m/s to km/h
            "averageSpeed": averageSpeed ?? 0,
            "timestamp": ISO8601DateFormatter().string(from: location.timestamp)
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            print("JSON serialization error: \(error)")
            completion?(false)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let response = response as? HTTPURLResponse,
                  error == nil,
                  (200...299).contains(response.statusCode) else {
                print("Live location sending error: \(error?.localizedDescription ?? "No error info")")
                completion?(false)
                return
            }
            completion?(true)
        }.resume()
    }

    func sendDutySummary(routeDescription: String, averageSpeed: Double, locations: [CLLocation], completion: @escaping (Bool) -> Void) {

        guard let url = URL(string: dutySummaryURL) else {
            completion(false)
            return
        }

        let locationsPayload = locations.map { loc in
            ["latitude": loc.coordinate.latitude,
             "longitude": loc.coordinate.longitude,
             "timestamp": ISO8601DateFormatter().string(from: loc.timestamp)]
        }

        let payload: [String: Any] = [
            "routeDescription": routeDescription,
            "averageSpeed": averageSpeed,
            "locations": locationsPayload
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(UserDefaults.standard.string(forKey: "jwt_token") ?? "")", forHTTPHeaderField: "Authorization")

        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let response = response as? HTTPURLResponse,
                  error == nil,
                  (200...299).contains(response.statusCode) else {
                print("Duty summary sending error: \(error?.localizedDescription ?? "No error info")")
                completion(false)
                return
            }
            completion(true)
        }.resume()
    }
}
