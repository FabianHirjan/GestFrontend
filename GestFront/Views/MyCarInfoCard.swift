//
//  MyCarInfoCard.swift
//  GestFront
//
//  Created by Fabian Andrei Hirjan on 22.05.2025.
//
import SwiftUI

struct MyCarInfoCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.body)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}
