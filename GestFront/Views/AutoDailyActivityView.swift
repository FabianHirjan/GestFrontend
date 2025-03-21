//
//  AutoDailyActivityView.swift
//  GestFront
//
//  Created by Fabian Andrei Hirjan on 21.03.2025.
//


import SwiftUI

struct AutoDailyActivityView: View {
    @StateObject var viewModel: AutoDailyActivityViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Form {
            Section(header: Text("Generated Route")) {
                TextEditor(text: $viewModel.descriptionText)
                    .frame(height: 150)
                    .disabled(true)
            }

            Section(header: Text("Activity details")) {
                TextField("Kilometers", text: $viewModel.kilometers)
                    .keyboardType(.numberPad)

                TextField("Fuel Consumption", text: $viewModel.fuelConsumption)
                    .keyboardType(.decimalPad)

                DatePicker("Date", selection: $viewModel.date, displayedComponents: .date)
                    .disabled(true)
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage).foregroundColor(.red)
            }

            Button(action: viewModel.createActivity) {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text("Save Daily Activity")
                }
            }
        }
        .navigationTitle("Finish Duty")
        .onReceive(viewModel.$creationSuccess) { success in
            if success {
                dismiss()
            }
        }
    }
}
