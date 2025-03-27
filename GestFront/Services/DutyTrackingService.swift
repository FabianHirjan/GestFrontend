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
    
    private let liveLocationURL = URL(string: "\(Config.baseURL)/users/location")!
    private let dutySummaryURL = URL(string: "\(Config.baseURL)/dailyactivities")!
    
    func sendLiveLocation(location: CLLocation, averageSpeed: Double) {
        var request = URLRequest(url: liveLocationURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(getAuthToken())", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("Error serializing live location body: \(error.localizedDescription)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending live location: \(error.localizedDescription)")
                return
            }
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("Live location sent successfully.")
            } else {
                print("Unexpected response: \(String(describing: response))")
            }
        }.resume()
    }

    func sendDutySummary(routeDescription: String, averageSpeed: Double, locations: [CLLocation], completion: @escaping (Bool) -> Void) {
        var request = URLRequest(url: dutySummaryURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(getAuthToken())", forHTTPHeaderField: "Authorization")

        let payload: [String: Any] = [
            "description": routeDescription,
            "kilometers": locations.enumerated().dropFirst().reduce(0.0) { (result, next) in
                result + next.element.distance(from: locations[next.offset - 1])
            } / 1000.0,            "fuelConsumption": 0.0, // Placeholder, updated by user later
            "date": ISO8601DateFormatter().string(from: Date())
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            print("Error serializing duty summary body: \(error.localizedDescription)")
            completion(false)
            return
        }

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

    private func getAuthToken() -> String {
        return UserDefaults.standard.string(forKey: "jwt_token") ?? ""
    }
}

