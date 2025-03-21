// DutyTrackingViewModel.swift

import SwiftUI
import CoreLocation

class DutyTrackingViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = DutyTrackingViewModel()

    @Published var isDutyActive = UserDefaults.standard.bool(forKey: "isDutyActive")
    @Published var locationsVisited: [CLLocation] = []
    @Published var currentLocation: CLLocation?
    @Published var averageSpeed: Double = 0
    @Published var routeDescription = ""
    @Published var didEndDuty: Bool = false
    @Published var calculatedDutyDetails: (description: String, kilometers: Int, fuelConsumption: Double)?

    private var locationManager = CLLocationManager()
    private var speedSamples: [Double] = []
    private var timer: Timer?

    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
    }

    func startDuty() {
        isDutyActive = true
        UserDefaults.standard.set(true, forKey: "isDutyActive")
        locationsVisited = []
        speedSamples = []
        routeDescription = ""
        calculatedDutyDetails = nil
        locationManager.startUpdatingLocation()
        startTimerForAverageSpeed()
    }

    func stopDuty() {
        isDutyActive = false
        UserDefaults.standard.set(false, forKey: "isDutyActive")
        locationManager.stopUpdatingLocation()
        timer?.invalidate()

        let details = calculateDutyDetails()

        DispatchQueue.main.async {
            self.calculatedDutyDetails = details
            self.didEndDuty = true
        }

        sendDutyDataToBackend()
    }


    private func startTimerForAverageSpeed() {
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            if !self.speedSamples.isEmpty {
                self.averageSpeed = self.speedSamples.reduce(0, +) / Double(self.speedSamples.count)
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        DispatchQueue.main.async {
            self.currentLocation = loc
            self.locationsVisited.append(loc)

            if loc.speed >= 0 {
                self.speedSamples.append(loc.speed * 3.6)
            }

            DutyTrackingService.shared.sendLiveLocation(
                location: loc,
                averageSpeed: self.averageSpeed
            )
        }
    }

    private func generateRouteDescription() {
        routeDescription = locationsVisited
            .map { "\($0.coordinate.latitude),\($0.coordinate.longitude)" }
            .joined(separator: " -> ")
    }

    func calculateDutyDetails() -> (description: String, kilometers: Int, fuelConsumption: Double) {
        generateRouteDescription()

        let distance = locationsVisited.reduce(0.0) { result, location in
            guard let last = locationsVisited.first else { return result }
            return result + location.distance(from: last)
        } / 1000.0

        let consumptionEstimate = distance / 15.0

        return (
            description: routeDescription,
            kilometers: Int(distance.rounded()),
            fuelConsumption: Double(consumptionEstimate.rounded(toPlaces: 2))
        )
    }

    private func sendDutyDataToBackend() {
        generateRouteDescription()

        DutyTrackingService.shared.sendDutySummary(
            routeDescription: routeDescription,
            averageSpeed: averageSpeed,
            locations: locationsVisited
        ) { success in
            if success {
                print("Duty data successfully sent!")
            } else {
                print("Failed to send duty data.")
            }
        }
    }
}

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
