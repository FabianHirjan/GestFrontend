// Services/AuthService.swift
import Foundation

class AuthService {
    static let shared = AuthService()
    private let networkManager = NetworkManager.shared
    
    private init() {}
    
    func login(username: String, password: String, completion: @escaping (Result<(token: String, role: String), Error>) -> Void) {
        guard let url = URL(string: "\(Config.baseURL)/auth/login") else { return }
        let body = ["username": username, "password": password]
        let request = networkManager.createRequest(url: url, method: "POST", body: body)
        
        networkManager.performRequest(request) { (result: Result<[String: String], Error>) in
            switch result {
            case .success(let json):
                guard let token = json["token"], let role = json["role"] else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                    return
                }
                UserDefaults.standard.set(token, forKey: "jwt_token")
                UserDefaults.standard.set(role, forKey: "user_role")
                completion(.success((token, role)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func validateToken(completion: @escaping (Bool) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "jwt_token"),
              let url = URL(string: "\(Config.baseURL)/auth/validate") else {
            completion(false)
            return
        }
        let request = networkManager.createRequest(url: url, method: "GET", token: token)
        networkManager.performRequest(request) { (result: Result<String, Error>) in
            switch result {  // Corectăm verificarea
            case .success:
                completion(true)
            case .failure:
                completion(false)
            }
        }
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: "jwt_token")
        UserDefaults.standard.removeObject(forKey: "user_role")
        UserDefaults.standard.set(false, forKey: "isDutyActive")
    }
}
