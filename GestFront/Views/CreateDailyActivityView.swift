import SwiftUI

struct CreateDailyActivityView: View {
    @StateObject var viewModel: CreateDailyActivityViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Form {
            Section(header: Text("Activity Info")) {
                // Description (non-editable)
                Text(viewModel.descriptionText)
                    .foregroundColor(.gray)
                    .padding(.vertical, 8)

                // Kilometers (non-editable)
                Text("\(viewModel.kilometers) km")
                    .foregroundColor(.gray)
                    .padding(.vertical, 8)

                // Fuel Consumption (editable)
                TextField("Fuel Consumption (liters)", text: $viewModel.fuelConsumption)
                    .keyboardType(.decimalPad)

                // Date (non-editable)
                Text(viewModel.date, style: .date)
                    .foregroundColor(.gray)
                    .padding(.vertical, 8)
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
