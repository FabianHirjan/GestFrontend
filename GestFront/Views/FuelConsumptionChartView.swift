//
//  FuelConsumptionChartView.swift
//  GestFront
//
//  Created by Fabian Andrei Hirjan on 21.03.2025.
//


import SwiftUI
import Charts

struct FuelConsumptionChartView: View {
    let data: [(date: String, consumption: Double)]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Fuel Consumption")
                .font(.headline)
                .padding(.bottom, 8)

            Chart(data, id: \.date) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Fuel Consumption", point.consumption)
                )
                .interpolationMethod(.catmullRom)
                .symbol(Circle())
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 6))
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
}
