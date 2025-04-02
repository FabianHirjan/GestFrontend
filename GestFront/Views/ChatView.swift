import SwiftUI

struct ChatView: View {
    @ObservedObject var chatManager: ChatWebSocketManager
    
    // Utilizatorul cu care discut
    let otherUser: UserDTO
    
    @State private var newMessageText: String = ""
    
    var body: some View {
        VStack {
            // Afișăm toate mesajele (istoric + mesaje noi)
            List(chatManager.messages) { msg in
                if msg.senderId == chatManager.currentUserId {
                    // Mesaj trimis de mine
                    HStack {
                        Spacer()
                        Text(msg.message)
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                } else {
                    // Mesaj primit
                    HStack {
                        Text(msg.message)
                            .padding(8)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(10)
                        Spacer()
                    }
                }
            }
            
            // TextField + buton "Trimite"
            HStack {
                TextField("Scrie un mesaj...", text: $newMessageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Trimite") {
                    sendCurrentMessage()
                }
            }
            .padding()
        }
        .navigationTitle("Chat cu \(otherUser.username)")
        .onAppear {
            // 1) Connect to WebSocket
            chatManager.connect()
            // 2) Load the entire conversation from REST
            chatManager.fetchConversation(with: Int(otherUser.id))
        }
        .onDisappear {
            // Optionally close the connection on exit
            // chatManager.disconnect()
        }
    }
    
    func sendCurrentMessage() {
        guard !newMessageText.isEmpty else { return }
        chatManager.sendMessage(
            senderId: chatManager.currentUserId,
            receiverId: Int(otherUser.id),
            text: newMessageText
        )
        newMessageText = ""
    }
}
