//
//  AllCarsView.swift
//  GestFront
//
//  Created by Fabian Andrei Hirjan on 27.03.2025.
//

import SwiftUI

struct AllCarsView: View {
    @StateObject private var viewModel = AllCarsViewModel()
    @State private var showingAssignSheet = false
    @State private var selectedCarId: Int?
    
    var body: some View {
        NavigationView {
            content
                .navigationTitle("All Cars")
                .onAppear {
                    viewModel.fetchCars()
                }
                .sheet(isPresented: $showingAssignSheet) {
                    AssignDriverView(carId: selectedCarId ?? 0, viewModel: viewModel)
                }
        }
    }
    
    private var content: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading cars...")
            } else if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            } else {
                List(viewModel.cars) { car in
                    carRow(for: car)
                }
            }
        }
    }
    
    private func carRow(for car: CarDTO) -> some View {
        HStack {
            Text("🚗")
                .font(.title)
            VStack(alignment: .leading) {
                Text("\(car.carMake.make ?? "Unknown") \(car.carModel.model ?? "Unknown")")
                    .font(.headline)
                Text("Plate: \(car.licensePlate)")
                    .font(.subheadline)
                Text("Driver: Unassigned") // Placeholder until driver info is added    
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Button("Assign") {
                selectedCarId = Int(car.id)
                showingAssignSheet = true
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
        }
    }
}

struct AssignDriverView: View {
    let carId: Int
    @ObservedObject var viewModel: AllCarsViewModel
    @State private var userId: String = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Text("Assign Driver to Car")
                .font(.headline)
                .padding()
            
            TextField("Enter User ID", text: $userId)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .padding()
            
            Button("Assign") {
                if let id = Int(userId) {
                    viewModel.assignCar(carId: carId, userId: id)
                    dismiss()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .padding()
            
            Button("Cancel") {
                dismiss()
            }
            .buttonStyle(.bordered)
            .tint(.red)
        }
        .padding()
    }
}

#Preview {
    AllCarsView()
}
