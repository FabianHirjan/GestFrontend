//
//  RealTimeTrackingService.swift
//  GestFront
//
//  Created by Fabian Andrei Hirjan on 21.03.2025.
//


//
//  RealTimeTrackingService.swift
//  GestFront
//

import Foundation

class RealTimeTrackingService: ObservableObject {
    static let shared = RealTimeTrackingService()
    
    @Published var userLocations: [UserLocation] = []
    private var webSocketTask: URLSessionWebSocketTask?
    private let jwtToken: String
    
    init() {
        // Retrieve the admin JWT token from UserDefaults (set during login)
        self.jwtToken = UserDefaults.standard.string(forKey: "jwt_token") ?? ""
        connect()
    }
    
    func connect() {
        guard let url = URL(string: "wss://gest-app-bachelors-production-7d2e.up.railway.app/ws/user-tracking") else { return }
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: request)
        webSocketTask?.resume()
        receiveMessages()
    }
    
    private func receiveMessages() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    if let data = text.data(using: .utf8),
                       let location = try? JSONDecoder().decode(UserLocation.self, from: data) {
                        DispatchQueue.main.async {
                            // Remove duplicates based on userId and keep the latest
                            if let index = self?.userLocations.firstIndex(where: { $0.userId == location.userId }) {
                                self?.userLocations[index] = location
                            } else {
                                self?.userLocations.append(location)
                            }
                        }
                    }
                default:
                    break
                }
                self?.receiveMessages() // Continue listening
            case .failure(let error):
                print("WebSocket error: \(error.localizedDescription)")
            }
        }
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        userLocations.removeAll()
    }
}

struct UserLocation: Identifiable, Codable {
    let id = UUID() // Unique ID for SwiftUI
    let userId: Int
    let username: String
    let latitude: Double
    let longitude: Double
    let timestamp: String
}
