import SwiftUI

struct SearchUserView: View {
    @State private var searchText: String = ""
    @State private var searchResults: [UserDTO] = []
    @State private var recentChats: [UserDTO] = []
    
    // Id-ul user-ului logat
    let currentUserId: Int
    
    var body: some View {
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
    
    func searchUsers() {
        UserService.shared.searchUsers(username: searchText) { result in
            switch result {
            case .success(let users):
                DispatchQueue.main.async {
                    self.searchResults = users
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
                let uniqueUsers = Array(Set(users))
                DispatchQueue.main.async {
                    self.recentChats = uniqueUsers
                }
            case .failure(let error):
                print("Eroare la fetchRecentChats: \(error)")
            }
        }
    }
}
