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
                    
                    // Câmp pentru consumul de combustibil
                    TextField("Fuel Consumption (L/100km)",
                              value: $viewModel.fuelConsumption,
                              formatter: NumberFormatter.decimalWithOneFractionDigit)
                        .keyboardType(.decimalPad)
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
                    }
                    .disabled(viewModel.isSubmitting)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onChange(of: viewModel.submissionSuccess) { success in
                if success {
                    dismiss()
                }
            }
        }
    }
}

// Formatter simplu pentru un număr cu max 1 zecimală
extension NumberFormatter {
    static var decimalWithOneFractionDigit: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 0
        return formatter
    }
}
