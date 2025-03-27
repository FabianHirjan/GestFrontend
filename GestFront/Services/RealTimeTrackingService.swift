// Services/RealTimeTrackingService.swift
import Foundation

// Definim UserLocation în același fișier (sau mută în Models/UserLocation.swift)
struct UserLocation: Identifiable, Codable {
    let id = UUID()
    let userId: Int
    let username: String
    let latitude: Double
    let longitude: Double
    let timestamp: String
}

class RealTimeTrackingService: ObservableObject {
    static let shared = RealTimeTrackingService()
    
    @Published var userLocations: [UserLocation] = []
    private var webSocketTask: URLSessionWebSocketTask?
    private let jwtToken: String
    
    private init() {
        self.jwtToken = UserDefaults.standard.string(forKey: "jwt_token") ?? ""
        connect()
    }
    
    func connect() {
        guard let url = URL(string: "\(Config.wsURL)/user-tracking") else { return }
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
                self?.receiveMessages()
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
