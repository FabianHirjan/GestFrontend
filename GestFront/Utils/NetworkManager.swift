import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    func createRequest(url: URL, method: String, body: [String: Any]? = nil, token: String? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        
        // Debug: Afișează detaliile request-ului creat
        print("=== Created Request ===")
        print("URL: \(request.url?.absoluteString ?? "nil")")
        print("Method: \(request.httpMethod ?? "nil")")
        print("Headers: \(request.allHTTPHeaderFields ?? [:])")
        if let httpBody = request.httpBody, let bodyString = String(data: httpBody, encoding: .utf8) {
            print("Body: \(bodyString)")
        }
        print("=======================\n")
        
        return request
    }
    
    func performRequest<T: Decodable>(_ request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) {
        // Debug: Afișează detaliile request-ului înainte de a fi trimis
        print("=== Performing Request ===")
        print("URL: \(request.url?.absoluteString ?? "nil")")
        print("Method: \(request.httpMethod ?? "nil")")
        print("Headers: \(request.allHTTPHeaderFields ?? [:])")
        if let httpBody = request.httpBody, let bodyString = String(data: httpBody, encoding: .utf8) {
            print("Body: \(bodyString)")
        }
        print("==========================\n")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Request error: \(error)")
                completion(.failure(error))
                return
            }
            guard let data = data, let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                let error = NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error"])
                print("Server error with status code: \(statusCode)")
                completion(.failure(error))
                return
            }
            do {
                let result = try JSONDecoder().decode(T.self, from: data)
                print("=== Response Data ===")
                print(String(data: data, encoding: .utf8) ?? "unable to decode response")
                print("=====================\n")
                completion(.success(result))
            } catch {
                print("Decoding error: \(error)")
                print("Raw Response Data: \(String(data: data, encoding: .utf8) ?? "unable to decode response")")
                completion(.failure(error))
            }
        }.resume()
    }
    
    func performVoidRequest(_ request: URLRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        // Debug: Afișează detaliile request-ului înainte de a fi trimis
        print("=== Performing Void Request ===")
        print("URL: \(request.url?.absoluteString ?? "nil")")
        print("Method: \(request.httpMethod ?? "nil")")
        print("Headers: \(request.allHTTPHeaderFields ?? [:])")
        if let httpBody = request.httpBody, let bodyString = String(data: httpBody, encoding: .utf8) {
            print("Body: \(bodyString)")
        }
        print("===============================\n")
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print("Request error: \(error)")
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                let error = NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error"])
                print("Server error with status code: \(statusCode)")
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }.resume()
    }
}
