import SwiftUI

struct MenuView: View {
    @StateObject private var view_model = MenuViewModel()
    
    var body: some View {
        NavigationStack {
            if view_model.is_logged_in {
                VStack(spacing: 20) {
                    Text("Main Menu")
                        .font(.largeTitle)
                        .padding()
                    
                    NavigationLink(destination: MyCarView()) {
                        Text("My Car")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                    
                    if UserDefaults.standard.string(forKey: "user_role") == "Admin" {
                        NavigationLink(destination: AllCarsView()) {
                            Text("View All Cars")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                        
                        NavigationLink(destination: AdminTrackingView()) {
                            Text("Real-Time Tracking")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                    }
                    
                    // --- NOUL BUTON DE MESSENGER ---
                    let userId = UserDefaults.standard.integer(forKey: "user_id")
                    if userId != 0 {
                        NavigationLink(destination: {
                            // Când intri în Messenger, creezi un ChatWebSocketManager
                            // cu userId-ul curent, iar ecranul de start va fi SearchUserView:
                            SearchUserView(currentUserId: userId)
                        }) {
                            Text("Messenger")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                    }
                    
                    // --- Butonul de Logout ---
                    Button("Logout") {
                        view_model.logout()
                    }
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding()
            } else {
                LoginView()
            }
        }
    }
}
