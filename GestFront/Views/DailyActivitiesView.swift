//
//  DailyActivitiesView.swift
//  GestFront
//

import SwiftUI

struct DailyActivitiesView: View {
    @StateObject private var viewModel = DailyActivitiesViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading activities...")
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                } else {
                    List(viewModel.activities) { activity in
                        VStack(alignment: .leading) {
                            Text(activity.description)
                                .font(.headline)
                            Text("Distance: \(String(format: "%.2f", activity.kilometers)) km")
                            Text("Date: \(activity.date)")
                            if let fuel = activity.fuelConsumption {
                                Text("Fuel: \(String(format: "%.1f", fuel)) L/100km")
                            }
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
}

#Preview {
    DailyActivitiesView()
}
