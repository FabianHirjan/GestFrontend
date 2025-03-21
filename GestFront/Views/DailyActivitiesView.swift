// Views/DailyActivitiesView.swift

import SwiftUI

struct DailyActivitiesView: View {
    @StateObject private var viewModel = DailyActivitiesViewModel()
    
    var body: some View {
        List {
            if viewModel.isLoading {
                Text("Loading...")
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage).foregroundColor(.red)
            } else {
                ForEach(viewModel.activities, id: \.id) { activity in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Description: \(activity.description)")
                            .font(.headline)
                        Text("Kilometers: \(activity.kilometers)")
                        Text("Fuel: \(activity.fuelConsumption)")
                        Text("Date: \(activity.date)")
                        Text("Approved: \(activity.approved ? "Yes" : "No")")
                            .foregroundColor(activity.approved ? .green : .red)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Daily Activities")
        .onAppear {
            viewModel.fetchActivities()
        }
    }
}
