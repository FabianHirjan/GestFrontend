import SwiftUI
import GoogleMaps

struct VirtualCockpitView: View {
    @ObservedObject var trackingVM: DutyTrackingViewModel
    @Binding var path: GMSMutablePath
    @State private var elapsedTime: String = "00:00:00"
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss
    
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
        ZStack {
            GoogleMapsView(
                currentLocation: $trackingVM.currentLocation,
                path: $path,
                destinationCoordinate: trackingVM.destinationCoordinate
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Spacer()
                    Text("Speed Limit: \(String(format: "%.0f", trackingVM.speedLimit)) km/h")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(trackingVM.currentSpeed > trackingVM.speedLimit ? .red : .white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(8)
                        .padding(.top, 40)
                        .padding(.trailing, 16)
                }
                Spacer()
            }
            
            VStack {
                Spacer()
                
                if let error = errorMessage {
                    Text(error)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(8)
                        .padding(.bottom, 8)
                }
                
                ZStack {
                    Path { path in
                        path.addArc(
                            center: CGPoint(x: 150, y: 150),
                            radius: 120,
                            startAngle: .degrees(180),
                            endAngle: .degrees(0),
                            clockwise: false
                        )
                    }
                    .stroke(Color.gray.opacity(0.3), lineWidth: 20)
                    
                    Path { path in
                        let maxSpeed: Double = 120
                        let endAngle = 180 * (1 - min(trackingVM.currentSpeed / maxSpeed, 1))
                        path.addArc(
                            center: CGPoint(x: 150, y: 150),
                            radius: 120,
                            startAngle: .degrees(180),
                            endAngle: .degrees(endAngle),
                            clockwise: false
                        )
                    }
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .green],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 20
                    )
                    .animation(.easeInOut(duration: 0.3), value: trackingVM.currentSpeed)
                    
                    Text("\(String(format: "%.1f", trackingVM.currentSpeed)) km/h")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .offset(y: 30)
                }
                .frame(width: 300, height: 180)
                .background(Color.white.opacity(0.9))
                .cornerRadius(16)
                .shadow(radius: 5)
                
                Text("Time Since Start: \(elapsedTime)")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(8)
                
                if trackingVM.currentTask != nil {
                    Button("Mark Checkpoint") {
                        trackingVM.markCheckpoint { result in
                            switch result {
                            case .success:
                                errorMessage = nil
                                print("Checkpoint marked successfully")
                            case .failure(let error):
                                errorMessage = error.localizedDescription
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .padding(.bottom, 8)
                }
                
                Button("Stop Duty") {
                    trackingVM.stopDuty()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .padding(.bottom, 40)
            }
        }
        .onReceive(timer) { _ in
            updateElapsedTime()
        }
    }
}
