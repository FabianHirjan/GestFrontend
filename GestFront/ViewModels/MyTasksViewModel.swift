import Foundation

class MyTasksViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let networkManager = NetworkManager.shared
    
    func fetchTasks() {
        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int,
              let url = URL(string: "\(Config.baseURL)/tasks/assigned-to/\(userId)") else {
            errorMessage = "Invalid user ID or URL"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        guard let token = UserDefaults.standard.string(forKey: "jwt_token") else {
            errorMessage = "No authentication token found"
            isLoading = false
            return
        }
        
        let request = networkManager.createRequest(url: url, method: "GET", token: token)
        networkManager.performRequest(request) { [weak self] (result: Result<[Task], Error>) in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let tasks):
                    self?.tasks = tasks
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func startTask(taskId: Int64, userId: Int, completion: @escaping (Result<Task, Error>) -> Void) {
        guard var urlComponents = URLComponents(string: "\(Config.baseURL)/tasks/\(taskId)/start"),
              let token = UserDefaults.standard.string(forKey: "jwt_token") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL or token"])))
            return
        }
        
        urlComponents.queryItems = [URLQueryItem(name: "userId", value: String(userId))]
        
        guard let url = urlComponents.url else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to construct URL"])))
            return
        }
        
        let request = networkManager.createRequest(url: url, method: "PUT", token: token)
        networkManager.performRequest(request) { (result: Result<Task, Error>) in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    func stopTask(taskId: Int64, userId: Int, completion: @escaping (Result<Task, Error>) -> Void) {
        guard var urlComponents = URLComponents(string: "\(Config.baseURL)/tasks/\(taskId)/stop"),
              let token = UserDefaults.standard.string(forKey: "jwt_token") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL or token"])))
            return
        }
        
        urlComponents.queryItems = [URLQueryItem(name: "userId", value: String(userId))]
        
        guard let url = urlComponents.url else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to construct URL"])))
            return
        }
        
        let request = networkManager.createRequest(url: url, method: "PUT", token: token)
        networkManager.performRequest(request) { (result: Result<Task, Error>) in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    func completeTask(taskId: Int64, userId: Int, completion: @escaping (Result<Task, Error>) -> Void) {
        guard var urlComponents = URLComponents(string: "\(Config.baseURL)/tasks/\(taskId)/complete"),
              let token = UserDefaults.standard.string(forKey: "jwt_token") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL or token"])))
            return
        }
        
        urlComponents.queryItems = [URLQueryItem(name: "userId", value: String(userId))]
        
        guard let url = urlComponents.url else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to construct URL"])))
            return
        }
        
        let request = networkManager.createRequest(url: url, method: "PUT", token: token)
        networkManager.performRequest(request) { (result: Result<Task, Error>) in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}
