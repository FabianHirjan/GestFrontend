import SwiftUI

struct MenuView: View {
    @StateObject private var view_model = MenuViewModel()
    
    var body: some View {
        NavigationStack {
            if view_model.is_logged_in {
                ZStack {
                    // Gradient background
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // Page title with shadow
                            Text("🚗 Main Menu")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 2)
                                .padding(.top, 40)
                            
                            // Grid for Metro-style tiles
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 15),
                                GridItem(.flexible(), spacing: 15)
                            ], spacing: 15) {
                                // My Car Button
                                NavigationLink(destination: MyCarView()) {
                                    MetroTile(
                                        title: "My Car 🚘",
                                        color: .cyan,
                                        shadowColor: .cyan.opacity(0.5)
                                    )
                                }
                                .buttonStyle(MetroButtonStyle())
                                
                                // Messenger Button
                                let userId = UserDefaults.standard.integer(forKey: "user_id")
                                if userId != 0 {
                                    NavigationLink(destination: SearchUserView(currentUserId: userId)) {
                                        MetroTile(
                                            title: "Messenger 💬",
                                            color: .blue,
                                            shadowColor: .blue.opacity(0.5)
                                        )
                                    }
                                    .buttonStyle(MetroButtonStyle())
                                }
                                
                                // Admin Buttons
                                if UserDefaults.standard.string(forKey: "user_role") == "Admin" {
                                    NavigationLink(destination: AllCarsView()) {
                                        MetroTile(
                                            title: "View All Cars 🏎️",
                                            color: .purple,
                                            shadowColor: .purple.opacity(0.5)
                                        )
                                    }
                                    .buttonStyle(MetroButtonStyle())
                                    
                                    
                                    NavigationLink(destination: AdminTrackingView()) {
                                        MetroTile(
                                            title: "Real-Time Tracking 📍",
                                            color: .green,
                                            shadowColor: .green.opacity(0.5)
                                        )
                                    }
                                    .buttonStyle(MetroButtonStyle())
                                }
                                
                                // Logout Button
                                Button(action: {
                                    view_model.logout()
                                }) {
                                    MetroTile(
                                        title: "Logout 🚪",
                                        color: .red,
                                        shadowColor: .red.opacity(0.5)
                                    )
                                }
                                .buttonStyle(MetroButtonStyle())
                            }
                            .padding(.horizontal)
                            
                            Spacer()
                        }
                        .padding(.bottom, 20)
                    }
                }
            } else {
                LoginView()
            }
        }
    }
}

// Custom Metro-style tile component
struct MetroTile: View {
    let title: String
    let color: Color
    let shadowColor: Color
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(color)
                .shadow(color: shadowColor, radius: 5, x: 0, y: 3)
            
            Text(title)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()
        }
        .frame(height: 100) // Fixed height for consistency
    }
}

// Custom ButtonStyle for Metro tiles with animation
struct MetroButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    MenuView()
}
