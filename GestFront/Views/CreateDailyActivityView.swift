// Views/CreateDailyActivityView.swift

import SwiftUI
struct CreateDailyActivityView: View {
    @StateObject var viewModel: CreateDailyActivityViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Form {
            Section(header: Text("Activity Info")) {
                TextField("Description", text: $viewModel.descriptionText)
                TextField("Kilometers", text: $viewModel.kilometers)
                    .keyboardType(.numberPad)
                TextField("Fuel Consumption", text: $viewModel.fuelConsumption)
                    .keyboardType(.decimalPad)
                DatePicker("Date", selection: $viewModel.date, displayedComponents: .date)
            }
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            Button(action: {
                viewModel.createActivity()
            }) {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text("Save Activity")
                }
            }
        }
        .navigationTitle("Create Daily Activity")
        .onReceive(viewModel.$creationSuccess) { success in
            if success {
                dismiss()
            }
        }
    }
}
