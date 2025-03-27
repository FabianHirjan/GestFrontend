//
//  CreateDailyActivityViewModel.swift
//  GestFront
//

import Foundation

class CreateDailyActivityViewModel: ObservableObject {
    @Published var description: String
    @Published var kilometers: Double
    @Published var date: Date
    @Published var isSubmitting = false
    @Published var errorMessage: String?
    @Published var submissionSuccess = false
    
    init(description: String, kilometers: Double, date: Date) {
        self.description = description
        self.kilometers = kilometers
        self.date = date
    }
    
    func submitActivity() {
        isSubmitting = true
        errorMessage = nil
        
        DailyActivityService.shared.createActivity(
            description: description,
            kilometers: kilometers,
            date: date
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isSubmitting = false
                switch result {
                case .success(let id):
                    print("Activity created with ID: \(id)")
                    self.submissionSuccess = true
                case .failure(let error):
                    self.errorMessage = "Failed to submit activity: \(error.localizedDescription)"
                }
            }
        }
    }
}
