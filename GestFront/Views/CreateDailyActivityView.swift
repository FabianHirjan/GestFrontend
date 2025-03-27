//
//  CreateDailyActivityView.swift
//  GestFront
//

import SwiftUI

struct CreateDailyActivityView: View {
    @ObservedObject var viewModel: CreateDailyActivityViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Activity Details")) {
                    TextField("Description", text: $viewModel.description)
                    Text("Kilometers: \(String(format: "%.2f", viewModel.kilometers)) km")
                        .foregroundColor(.gray)
                    DatePicker("Date", selection: $viewModel.date, displayedComponents: .date)
                }
                
                if viewModel.isSubmitting {
                    ProgressView("Submitting...")
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Create Activity")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.submitActivity()
                        if viewModel.submissionSuccess {
                            dismiss()
                        }
                    }
                    .disabled(viewModel.isSubmitting)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    CreateDailyActivityView(viewModel: CreateDailyActivityViewModel(description: "Test Duty", kilometers: 10.5, date: Date()))
}
