//
//  SpeedometerView.swift
//  GestFront
//
//  Created by Fabian Andrei Hirjan on 22.05.2025.
//

import SwiftUI
struct SpeedometerView: View {
    @ObservedObject var trackingVM: DutyTrackingViewModel
    @State private var elapsedTime: String = "00:00:00"
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private func updateElapsedTime() {
        guard let startTime = trackingVM.dutyStartTime else {
            elapsedTime = "00:00:00"
            return
        }
        let interval = Date().timeIntervalSince(startTime)
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        elapsedTime = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Speedometer Gauge
            Gauge(value: trackingVM.currentSpeed, in: 0...120) {
                Text("Speed")
            } currentValueLabel: {
                Text("\(String(format: "%.1f", trackingVM.currentSpeed)) km/h")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .gaugeStyle(.accessoryCircular)
            .tint(Gradient(colors: [.blue, .green]))
            .frame(width: 200, height: 200)
            
            // Time Since Duty Start
            Text("Time Since Start: \(elapsedTime)")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .onReceive(timer) { _ in
            updateElapsedTime()
        }
    }
}
