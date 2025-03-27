// Views/LoginView.swift
import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        NavigationStack {
            if viewModel.isLoading && !viewModel.isAuthenticated {
                ProgressView("Checking session...")
            } else if viewModel.isAuthenticated {
                MenuView()
            } else {
                VStack(spacing: 20) {
                    Text("Autentificare")
                        .font(.largeTitle)
                        .padding(.top, 40)
                    
                    TextField("Username", text: $viewModel.username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .padding(.horizontal)
                    
                    SecureField("Parola", text: $viewModel.password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button(action: viewModel.login) {
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("Login")
                                .fontWeight(.bold)
                        }
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Spacer()
                }
                .ignoresSafeArea(.keyboard, edges: .bottom) // Adăugăm pentru a evita conflictul
            }
        }
        .onAppear {
            viewModel.checkExistingSession()
        }
    }
}
