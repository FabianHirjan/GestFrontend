//
//  MenuView.swift
//  GestFront
//
//  Created by Fabian Andrei Hirjan on 21.03.2025.
//


// Views/MenuView.swift

import SwiftUI

struct MenuView: View {
    @StateObject private var viewModel = MenuViewModel()
    
    var body: some View {
        NavigationStack {
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
                // Mai adaugi și alte opțiuni de meniu:
                // e.g. NavigationLink(destination: ....) { Text("Profil") }
                
                Spacer()
            }
            .padding()
        }
    }
}
