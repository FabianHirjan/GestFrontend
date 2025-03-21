//
//  AuthService.swift
//  GestFront
//
//  Created by Fabian Andrei Hirjan on 21.03.2025.
//


// Services/AuthService.swift

import Foundation

class AuthService {
    static let shared = AuthService()
    
    private init() { }
    
    func login(username: String, password: String, completion: @escaping (Result<(token: String, role: String), Error>) -> Void) {
        // 1. Creezi URL-ul către endpoint-ul tău, ex: http://localhost:8080/api/auth/login
        guard let url = URL(string: "\(Config.baseURL)/auth/login") else {
            // Sau URL-ul real de producție
            print("URL invalid")
            return
        }
        
        // 2. Creezi request-ul
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 3. Struct pentru Body
        let body: [String: Any] = [
            "username": username,
            "password": password
        ]
        
        // 4. Transformi body-ul în JSON
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
            request.httpBody = jsonData
        } catch {
            print("Eroare la serializarea JSON: \(error)")
            completion(.failure(error))
            return
        }
        
        // 5. Faci apelul
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Verifici erorile de rețea
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Verifici dacă ai date + status code valid
            if let data = data,
               let httpResponse = response as? HTTPURLResponse {
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    // În caz de 401, 403, etc.
                    let statusError = NSError(domain: "", code: httpResponse.statusCode, userInfo: nil)
                    completion(.failure(statusError))
                    return
                }
                
                // Parsezi JSON-ul (așteptăm un obiect de forma: { "token": "...", "role": "..." } )
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let token = json["token"] as? String,
                       let role = json["role"] as? String {
                        // Returnezi token + role prin callback
                        completion(.success((token, role)))
                    } else {
                        let parsingError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Parsing error"])
                        completion(.failure(parsingError))
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
