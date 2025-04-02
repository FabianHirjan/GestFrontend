import Foundation



// Modelul pentru istoricul mesajelor aplatizat (fără obiecte nested)
struct HistoryMessageResponse: Codable {
    let senderId: Int
    let receiverId: Int
    let message: String
    let sentDate: String?  // Dacă dorești să folosești și data, altfel poți omite
}

class ChatWebSocketManager: ObservableObject {
    @Published var messages: [ChatMessage] = []

    private var webSocketTask: URLSessionWebSocketTask?
    let currentUserId: Int

    init(currentUserId: Int) {
        self.currentUserId = currentUserId
    }
    
    func connect() {
        guard let url = URL(string: "\(Config.wsURL)/messages?userId=\(currentUserId)") else {
            print("Eroare: URL invalid -> \(Config.wsURL)/messages?userId=\(currentUserId)")
            return
        }
        
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        receiveMessages()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
    
    private func receiveMessages() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                print("Eroare la primirea mesajului: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    if let data = text.data(using: .utf8) {
                        do {
                            let receivedChatMessage = try JSONDecoder().decode(ChatMessage.self, from: data)
                            DispatchQueue.main.async {
                                self.messages.append(receivedChatMessage)
                            }
                        } catch {
                            print("Eroare la decodarea JSON-ului: \(error)")
                        }
                    }
                case .data(let data):
                    print("A venit un mesaj binar, se aștepta text: \(data)")
                @unknown default:
                    print("Mesaj necunoscut!")
                }
            }
            self.receiveMessages()
        }
    }
    
    func sendMessage(senderId: Int, receiverId: Int, text: String) {
        let chatMessage = ChatMessage(senderId: senderId, receiverId: receiverId, message: text)
        do {
            let jsonData = try JSONEncoder().encode(chatMessage)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                let message = URLSessionWebSocketTask.Message.string(jsonString)
                webSocketTask?.send(message) { error in
                    if let error = error {
                        print("Eroare la trimiterea mesajului: \(error)")
                    } else {
                        print("Mesaj trimis cu succes!")
                    }
                }
            }
        } catch {
            print("Eroare la encodarea mesajului: \(error)")
        }
    }
    
    // Actualizarea metodei fetchConversation:
    // Se decodează [HistoryMessageResponse] și se mapează în [ChatMessage]
    func fetchConversation(with otherUserId: Int) {
        guard let url = URL(string: "http://192.168.1.243:8080/api/messages/history?user1=\(currentUserId)&user2=\(otherUserId)") else {
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    // Decodăm folosind modelul aplatizat HistoryMessageResponse
                    let serverMessages = try JSONDecoder().decode([HistoryMessageResponse].self, from: data)
                    
                    // Mapăm fiecare element la un ChatMessage
                    let flattened = serverMessages.map { msgResp in
                        ChatMessage(
                            senderId: msgResp.senderId,
                            receiverId: msgResp.receiverId,
                            message: msgResp.message
                        )
                    }
                    
                    DispatchQueue.main.async {
                        self.messages = flattened
                    }
                } catch {
                    print("Eroare la decodarea istoricului: \(error)")
                }
            }
        }.resume()
    }
}
