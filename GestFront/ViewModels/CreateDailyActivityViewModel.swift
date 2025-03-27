import SwiftUI

class CreateDailyActivityViewModel: ObservableObject {
    @Published var descriptionText: String
    @Published var kilometers: String
    @Published var fuelConsumption: String = "" // Empty by default, user will input this
    @Published var date: Date
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var creationSuccess: Bool = false

    init(description: String, kilometers: Int, date: Date) {
        self.descriptionText = description
        self.kilometers = "\(kilometers)"
        self.date = date
    }

    func createActivity() {
        isLoading = true
        errorMessage = nil
        
        guard let km = Int(kilometers) else {
            self.errorMessage = "Kilometers must be an integer!"
            self.isLoading = false
            return
        }
        
        guard let fuel = Double(fuelConsumption) else {
            self.errorMessage = "Fuel consumption must be a valid number!"
            self.isLoading = false
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        
        DailyActivityService.shared.createDailyActivity(
            description: descriptionText,
            kilometers: km,
            fuelConsumption: fuel,
            date: dateString
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(_):
                    self?.creationSuccess = true
                case .failure(let error):
                    self?.errorMessage = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
}
