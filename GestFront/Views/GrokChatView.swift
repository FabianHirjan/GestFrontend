import SwiftUI

struct GrokChatView: View {
    @StateObject private var viewModel = GrokChatViewModel()
    @State private var newMessageText: String = ""
    
    var body: some View {
        VStack {
            // Afișăm mesajele
            List(viewModel.messages) { msg in
                if msg.isUser {
                    // Mesaj trimis de utilizator
                    HStack {
                        Spacer()
                        Text(msg.text)
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                } else {
                    // Răspuns de la Grok
                    HStack {
                        Text(msg.text)
                            .padding(8)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(10)
                        Spacer()
                    }
                }
            }
            
            // TextField + buton "Trimite"
            HStack {
                TextField("Scrie un mesaj pentru Grok...", text: $newMessageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Trimite") {
                    sendMessage()
                }
                .disabled(newMessageText.isEmpty || viewModel.isLoading)
            }
            .padding()
        }
        .navigationTitle("Grok Assistant")
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .alert("Eroare", isPresented: $viewModel.showError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage ?? "A apărut o eroare.")
        }
    }
    
    private func sendMessage() {
        guard !newMessageText.isEmpty else { return }
        viewModel.sendMessage(newMessageText)
        newMessageText = ""
    }
}

class GrokChatViewModel: ObservableObject {
    @Published var messages: [GrokMessage] = []
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String? = nil
    
    private let baseURL = "http://localhost:8080/api/text/query"
    
    func sendMessage(_ text: String) {
        // Add user message
        messages.append(GrokMessage(text: text, isUser: true))
        
        // Prepare request
        let requestBody = ["text": text]
        guard let url = URL(string: baseURL),
              let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            showError(message: "Eroare la crearea cererii")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // Send request
        isLoading = true
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                // Check for network errors
                if let error = error {
                    self?.showError(message: "Eroare de rețea: \(error.localizedDescription)")
                    return
                }
                
                // Verify HTTP response
                guard let httpResponse = response as? HTTPURLResponse else {
                    self?.showError(message: "Răspuns invalid: Nu este răspuns HTTP")
                    return
                }
                
                // Log status code
                print("HTTP Status Code: \(httpResponse.statusCode)")
                
                // Check for successful status code
                guard (200...299).contains(httpResponse.statusCode) else {
                    self?.showError(message: "Eroare server: Cod HTTP \(httpResponse.statusCode)")
                    return
                }
                
                // Log raw response data
                if let data = data, let rawString = String(data: data, encoding: .utf8) {
                    print("Raw Response: \(rawString)")
                } else {
                    self?.showError(message: "Răspuns invalid: Date lipsă")
                    return
                }
                
                // Attempt to decode JSON
                do {
                    let json = try JSONDecoder().decode(GrokResponse.self, from: data!)
                    self?.messages.append(GrokMessage(text: json.response, isUser: false))
                } catch {
                    self?.showError(message: "Eroare la decodarea răspunsului: \(error.localizedDescription)")
                    print("Decoding Error: \(error)")
                }
            }
        }.resume()
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}

struct GrokMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

struct GrokResponse: Codable {
    let query: String
    let response: String
}
