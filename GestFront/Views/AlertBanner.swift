//
//  AlertBanner.swift
//  GestFront
//
//  Created by Fabian Andrei Hirjan on 22.05.2025.
//

import SwiftUI
struct AlertBanner: View {
    let message: String
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.white)
            Text(message)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.red)
        .cornerRadius(8)
    }
}
