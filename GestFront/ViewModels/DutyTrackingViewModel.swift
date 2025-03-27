//
//  DutyTrackingViewModel.swift
//  GestFront
//

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
    @Published var calculatedDutyDetails: (description: String, kilometers: Int, date: Date)?
    @Published var lastLocationName: String? // Added for last location display

    private var locationManager = CLLocationManager()
    private var speedSamples: [Double] = []
    private var timer: Timer?
    private let geocoder = CLGeocoder()
    private var readableLocations: [String] = []
    
    private var lastStoppedLocation: CLLocation?
    private var stoppedTimestamp: Date?
    private let stopThreshold: TimeInterval = 300 // 5 minutes in seconds
    private var startLocation: CLLocation?
    private var lastLiveUpdate: Date? // Throttle live updates

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
        readableLocations = []
        speedSamples = []
        routeDescription = ""
        calculatedDutyDetails = nil
        lastStoppedLocation = nil
        stoppedTimestamp = nil
        startLocation = nil
        lastLiveUpdate = nil
        locationManager.startUpdatingLocation()
        startTimerForAverageSpeed()
    }

    func stopDuty() {
        isDutyActive = false
        UserDefaults.standard.set(false, forKey: "isDutyActive")
        locationManager.stopUpdatingLocation()
        timer?.invalidate()

        if let lastLocation = locationsVisited.last {
            reverseGeocodeLocation(lastLocation) { readableName in
                if let readableName = readableName, !self.readableLocations.contains(readableName) {
                    self.readableLocations.append(readableName)
                    self.updateRouteDescription()
                }
            }
        }

        let details = calculateDutyDetails()

        DispatchQueue.main.async {
            self.calculatedDutyDetails = details
            self.didEndDuty = true
        }

        sendDutyDataToBackend()
    }
    
    func fetchLastLocation() {
        UserService.shared.fetchLastLocation { [weak self] result in
            switch result {
            case .success(let (latitude, longitude)):
                let location = CLLocation(latitude: latitude, longitude: longitude)
                self?.reverseGeocodeLocation(location) { readableName in
                    DispatchQueue.main.async {
                        self?.lastLocationName = readableName ?? "Unknown"
                    }
                }
            case .failure(let error):
                print("Error fetching last location: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.lastLocationName = "Unknown"
                }
            }
        }
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

            if self.startLocation == nil {
                self.startLocation = loc
                self.reverseGeocodeLocation(loc) { readableName in
                    if let readableName = readableName {
                        self.readableLocations.append(readableName)
                        self.updateRouteDescription()
                    }
                }
            }

            self.handleLocationUpdate(loc)

            // Throttle live location updates to every 5 seconds
            if self.lastLiveUpdate == nil || Date().timeIntervalSince(self.lastLiveUpdate!) >= 5 {
                DutyTrackingService.shared.sendLiveLocation(
                    location: loc,
                    averageSpeed: self.averageSpeed
                )
                self.lastLiveUpdate = Date()
            }
        }
    }

    private func handleLocationUpdate(_ location: CLLocation) {
        let isStopped = location.speed < 1.0
        if isStopped {
            if lastStoppedLocation == nil || location.distance(from: lastStoppedLocation!) > 50 {
                lastStoppedLocation = location
                stoppedTimestamp = Date()
            } else {
                checkAndAddStoppedLocation()
            }
        } else {
            lastStoppedLocation = nil
            stoppedTimestamp = nil
        }
    }

    private func checkAndAddStoppedLocation() {
        guard let stoppedLocation = lastStoppedLocation, let timestamp = stoppedTimestamp else { return }
        let timeElapsed = Date().timeIntervalSince(timestamp)
        if timeElapsed >= stopThreshold {
            reverseGeocodeLocation(stoppedLocation) { readableName in
                if let readableName = readableName, !self.readableLocations.contains(readableName) {
                    self.readableLocations.append(readableName)
                    self.updateRouteDescription()
                }
            }
            lastStoppedLocation = nil
            stoppedTimestamp = nil
        }
    }

    private func reverseGeocodeLocation(_ location: CLLocation, completion: @escaping (String?) -> Void) {
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                completion(nil)
                return
            }
            let city = placemark.locality ?? placemark.administrativeArea ?? "Unknown City"
            let street = placemark.thoroughfare ?? ""
            let readableName = street.isEmpty ? city : "\(city), \(street)"
            completion(readableName)
        }
    }

    private func updateRouteDescription() {
        routeDescription = readableLocations.joined(separator: " -> ")
    }

    func calculateDutyDetails() -> (description: String, kilometers: Int, date: Date) {
        updateRouteDescription()

        let distance = locationsVisited.reduce(0.0) { result, location in
            guard let last = locationsVisited.first(where: { $0 !== location }) else { return result }
            return result + location.distance(from: last)
        } / 1000.0

        return (
            description: routeDescription,
            kilometers: Int(distance.rounded()),
            date: Date()
        )
    }

    private func sendDutyDataToBackend() {
        updateRouteDescription()

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
