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
        
        networkManager.performRequest(request) { (result: Result<LoginResponse, Error>) in
            switch result {
            case .success(let loginResponse):
                UserDefaults.standard.set(loginResponse.token, forKey: "jwt_token")
                UserDefaults.standard.set(loginResponse.role, forKey: "user_role")
                completion(.success((loginResponse.token, loginResponse.role)))
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
        let request = networkManager.createRequest(url: url, method: "POST", token: token)
        networkManager.performRequest(request) { (result: Result<ValidateResponse, Error>) in
            switch result {
            case .success(let response):
                print("Validated user: \(response.username), role: \(response.role), userId: \(response.userId)")
                completion(true)
            case .failure(let error):
                print("Validation failed: \(error)")
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
