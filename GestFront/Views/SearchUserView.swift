import SwiftUI

struct SearchUserView: View {
    @State private var searchText: String = ""
    @State private var searchResults: [UserDTO] = []
    @State private var recentChats: [UserDTO] = []
    
    // Id-ul user-ului logat
    let currentUserId: Int
    
    // Static Grok user
    private let grokUser = UserDTO(
        id: -1,
        username: "Grok Assistant",
        email: nil,
        role: nil,
        firstName: nil,
        lastName: nil
    )
    
    var body: some View {
        NavigationStack {
            VStack {
                // Câmp de căutare
                HStack {
                    TextField("Caută utilizator...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Caută") {
                        searchUsers()
                    }
                }
                .padding()
                
                // Secțiune pentru Grok Assistant
                Text("Asistent")
                    .font(.headline)
                    .padding(.top)
                
                NavigationLink(destination: {
                    GrokChatView()
                }) {
                    HStack {
                        Image(systemName: "sparkles") // Icon to distinguish Grok
                            .foregroundColor(.blue)
                        Text(grokUser.username)
                            .foregroundColor(.blue)
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                .padding(.horizontal)
                
                Divider()
                
                // Lista cu conversații recente
                Text("Conversații recente")
                    .font(.headline)
                    .padding(.top)
                
                List(recentChats) { user in
                    NavigationLink(destination: {
                        ChatView(
                            chatManager: ChatWebSocketManager(currentUserId: currentUserId),
                            otherUser: user
                        )
                    }) {
                        Text(user.username)
                    }
                }
                
                Divider()
                
                // Rezultatele căutării
                Text("Rezultate căutare")
                    .font(.headline)
                
                List(searchResults) { user in
                    NavigationLink(destination: {
                        ChatView(
                            chatManager: ChatWebSocketManager(currentUserId: currentUserId),
                            otherUser: user
                        )
                    }) {
                        Text(user.username)
                    }
                }
            }
            .navigationTitle("Mesaje")
            .onAppear {
                fetchRecentChats()
            }
        }
    }
    
    func searchUsers() {
        UserService.shared.searchUsers(username: searchText) { result in
            switch result {
            case .success(let users):
                DispatchQueue.main.async {
                    // Exclude Grok from search results
                    self.searchResults = users.filter { $0.id != grokUser.id }
                }
            case .failure(let error):
                print("Eroare la căutarea utilizatorilor: \(error)")
            }
        }
    }
    
    func fetchRecentChats() {
        UserService.shared.fetchRecentChats(userId: currentUserId) { result in
            switch result {
            case .success(let users):
                let uniqueUsers = Array(Set(users)).filter { $0.id != grokUser.id }
                DispatchQueue.main.async {
                    self.recentChats = uniqueUsers
                }
            case .failure(let error):
                print("Eroare la fetchRecentChats: \(error)")
            }
        }
    }
}
