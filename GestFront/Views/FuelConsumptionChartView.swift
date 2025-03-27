//
//  FuelConsumptionChartView.swift
//  GestFront
//

import SwiftUI

struct FuelConsumptionChartView: View {
    let data: [(date: String, consumption: Double)]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Fuel Consumption")
                .font(.headline)
            ScrollView {
                ForEach(data, id: \.date) { item in
                    HStack {
                        Text(item.date)
                            .font(.subheadline)
                        Spacer()
                        Text(String(format: "%.1f L/100km", item.consumption))
                            .font(.subheadline)
                    }
                    .padding(.vertical, 4)
                }
            }
            .frame(maxHeight: 200)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

#Preview {
    FuelConsumptionChartView(data: [("2025-03-01", 5.5), ("2025-03-02", 6.2)])
}
