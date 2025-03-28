// Views/MenuView.swift
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
                        // Există deja buton pentru AllCarsView
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
                        
                        // Adăugăm butonul pentru Real-Time Tracking
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
