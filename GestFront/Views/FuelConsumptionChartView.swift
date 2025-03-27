//
//  FuelConsumptionChartView.swift
//  GestFront
//

import SwiftUI
import Charts

struct FuelConsumptionChartView: View {
    let data: [(date: String, consumption: Double)]
    
    // Structura pentru datele agregate necesare graficului
    private struct AggregatedChartData {
        let dailyAverages: [(date: Date, consumption: Double)]
        let trendLine: [(date: Date, consumption: Double)]
    }
    
    private var chartData: AggregatedChartData {
        aggregateData(data)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Fuel Consumption Trends")
                .font(.headline)
            
            Chart {
                // Bare pentru consumul zilnic mediu
                ForEach(chartData.dailyAverages, id: \.date) { item in
                    BarMark(
                        x: .value("Date", item.date, unit: .day),
                        y: .value("Consumption (L/100km)", item.consumption)
                    )
                    .foregroundStyle(.blue)
                }
                
                // Linia de trend (regresie liniară) peste consumul zilnic mediu
                ForEach(chartData.trendLine, id: \.date) { item in
                    LineMark(
                        x: .value("Date", item.date, unit: .day),
                        y: .value("Consumption (L/100km)", item.consumption)
                    )
                    .foregroundStyle(.red)
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.month().day())
                }
            }
            .chartYAxis {
                AxisMarks(values: .stride(by: 1.0)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: Decimal.FormatStyle.number.precision(.fractionLength(1)))
                }
            }
            // Eliminăm legenda pentru un aspect mai curat
            .chartLegend(.hidden)
            .frame(height: 250)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    // Agreghează datele pe zi și calculează linia de trend
    private func aggregateData(_ data: [(date: String, consumption: Double)]) -> AggregatedChartData {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // Formatul datelor
        
        // Agregarea consumului per zi (calculul mediei pentru fiecare zi)
        var dailyDict: [Date: [Double]] = [:]
        for entry in data {
            if let date = dateFormatter.date(from: entry.date) {
                dailyDict[date, default: []].append(entry.consumption)
            }
        }
        
        let dailyAverages = dailyDict.map { (date, consumptions) in
            (date: date, consumption: consumptions.reduce(0, +) / Double(consumptions.count))
        }
        .sorted { $0.date < $1.date }
        
        // Calculul liniei de trend folosind regresia liniară pe valorile zilnice medii
        let trendLine = linearRegression(data: dailyAverages)
        
        return AggregatedChartData(dailyAverages: dailyAverages, trendLine: trendLine)
    }
    
    // Regresie liniară simplă: folosește indexul în serie ca variabilă x
    private func linearRegression(data: [(date: Date, consumption: Double)]) -> [(date: Date, consumption: Double)] {
        guard !data.isEmpty else { return [] }
        
        let n = Double(data.count)
        let xValues = data.enumerated().map { Double($0.offset) }
        let yValues = data.map { $0.consumption }
        
        let sumX = xValues.reduce(0, +)
        let sumY = yValues.reduce(0, +)
        let sumXY = zip(xValues, yValues).map(*).reduce(0, +)
        let sumXX = xValues.map { $0 * $0 }.reduce(0, +)
        
        let slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX)
        let intercept = (sumY - slope * sumX) / n
        
        return data.enumerated().map { (index, item) in
            let x = Double(index)
            let y = slope * x + intercept
            return (date: item.date, consumption: y)
        }
    }
}

#Preview {
    FuelConsumptionChartView(data: [
        ("2025-03-01", 5.5),
        ("2025-03-01", 6.0),  // Două înregistrări pentru aceeași zi
        ("2025-03-02", 6.2),
        ("2025-03-02", 6.0),
        ("2025-03-03", 5.8),
        ("2025-03-04", 6.0),
        ("2025-03-04", 5.9),
        ("2025-03-05", 5.7),
        ("2025-03-06", 6.1),
        ("2025-03-07", 5.9),
        ("2025-03-07", 6.3),
        ("2025-03-08", 6.2)
    ])
}
