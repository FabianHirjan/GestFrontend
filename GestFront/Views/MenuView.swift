import SwiftUI

struct MenuView: View {
    @StateObject private var view_model = MenuViewModel()
    
    // User data from UserDefaults, non-optional
    private let username: String = {
        let value = UserDefaults.standard.string(forKey: "username")
        assert(value != nil, "Username must be set in UserDefaults")
        return value!
    }()
    
    private let userId = 1
    private let role: String = {
        let value = UserDefaults.standard.string(forKey: "user_role")
        assert(value != nil, "Role must be set in UserDefaults")
        return value!
    }()
    
    private let isActive = true // Simulating active status
    
    var body: some View {
        NavigationStack {
            if view_model.is_logged_in {
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 8) {
                        Text("CarGest")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                            .padding(.top, 20)
                        
                        Text(username)
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(.black)
                        
                        Text("Role: \(role), ID: \(userId)")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 8) {
                            Circle()
                                .frame(width: 10, height: 10)
                                .foregroundColor(isActive ? .green : .red)
                            Text(isActive ? "Active" : "Inactive")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.gray)
                        }
                        
                        Text("Connect with your fleet")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(.gray)
                            .padding(.bottom, 10)
                    }
                    
                    // 2x3 Button Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 0),
                        GridItem(.flexible(), spacing: 0)
                    ], spacing: 0) {
                        // My Car Button
                        NavigationLink(destination: MyCarView()) {
                            GridButton(
                                title: "My Car",
                                icon: "car.fill",
                                color: .orange
                            )
                        }
                        .offset(y: view_model.is_logged_in ? 0 : 50)
                        .opacity(view_model.is_logged_in ? 1 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1), value: view_model.is_logged_in)
                        
                        // Messenger Button
                        let userIdLocal = UserDefaults.standard.integer(forKey: "user_id")
                        if userIdLocal != 0 {
                            NavigationLink(destination: SearchUserView(currentUserId: userIdLocal)) {
                                GridButton(
                                    title: "Messenger",
                                    icon: "message.fill",
                                    color: .blue
                                )
                            }
                            .offset(y: view_model.is_logged_in ? 0 : 50)
                            .opacity(view_model.is_logged_in ? 1 : 0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2), value: view_model.is_logged_in)
                        }
                        
                        // View All Cars Button
                        if UserDefaults.standard.string(forKey: "user_role") == "Admin" {
                            NavigationLink(destination: AllCarsView()) {
                                GridButton(
                                    title: "View All Cars",
                                    icon: "car.2.fill",
                                    color: .purple
                                )
                            }
                            .offset(y: view_model.is_logged_in ? 0 : 50)
                            .opacity(view_model.is_logged_in ? 1 : 0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.3), value: view_model.is_logged_in)
                        }
                        
                        // Real-Time Tracking Button
                        if UserDefaults.standard.string(forKey: "user_role") == "Admin" {
                            NavigationLink(destination: AdminTrackingView()) {
                                GridButton(
                                    title: "Real-Time Tracking",
                                    icon: "mappin.circle.fill",
                                    color: .green
                                )
                            }
                            .offset(y: view_model.is_logged_in ? 0 : 50)
                            .opacity(view_model.is_logged_in ? 1 : 0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.4), value: view_model.is_logged_in)
                        }
                        
                        // Placeholder (could reuse or add another feature)
                        NavigationLink(destination: MyTasksView()) {
                            GridButton(
                                title: "Driving Team",
                                icon: "person.2.fill",
                                color: .gray
                            )
                        }
                        .offset(y: view_model.is_logged_in ? 0 : 50)
                        .opacity(view_model.is_logged_in ? 1 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.5), value: view_model.is_logged_in)
                        
                        // Placeholder (could reuse or add another feature)
                        if userIdLocal != 0 {
                            NavigationLink(destination: SearchUserView(currentUserId: userIdLocal)) {
                                GridButton(
                                    title: "Driving Team",
                                    icon: "person.2.fill",
                                    color: .gray
                                )
                            }
                            .offset(y: view_model.is_logged_in ? 0 : 50)
                            .opacity(view_model.is_logged_in ? 1 : 0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.6), value: view_model.is_logged_in)
                        }
                    }
                    
                    // Sign Out Button
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            view_model.logout()
                        }
                    }) {
                        Text("Sign Out")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black.opacity(0.8))
                    }
                    .offset(y: view_model.is_logged_in ? 0 : 50)
                    .opacity(view_model.is_logged_in ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.7), value: view_model.is_logged_in)
                }
                .background(Color.white.edgesIgnoringSafeArea(.all))
            } else {
                LoginView()
            }
        }
    }
}

// Custom grid button component
struct GridButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(1, contentMode: .fit) // Ensure square buttons
        .background(color)
        .overlay(
            Rectangle()
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    MenuView()
}
