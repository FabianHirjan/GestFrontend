import Foundation
import CoreLocation
import GoogleMaps

class DutyTrackingViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = DutyTrackingViewModel()
    
    @Published var isDutyActive: Bool = false
    @Published var currentLocation: CLLocation?
    @Published var lastLocationName: String?
    @Published var averageSpeed: Double = 0.0
    @Published var didEndDuty: Bool = false
    @Published var calculatedDutyDetails: DutyDetails?
    
    private let locationManager = CLLocationManager()
    private var locations: [CLLocation] = []
    private var lastLiveUpdate: Date?
    private let userId: String
    
    private override init() {
        self.userId = UserDefaults.standard.string(forKey: "user_id") ?? "unknown_user"
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startDuty() {
        guard !isDutyActive else { return }
        locationManager.startUpdatingLocation()
        isDutyActive = true
        locations.removeAll()
        averageSpeed = 0.0
        didEndDuty = false
        calculatedDutyDetails = nil
        print("Duty started for user: \(userId)")
    }
    
    func stopDuty() {
        guard isDutyActive else { return }
        locationManager.stopUpdatingLocation()
        isDutyActive = false
        
        // Construim doar local datele pentru Daily Activity,
        // fără să trimitem direct la server (ca să evităm dublarea).
        let routeDescription = "Duty from \(lastLocationName ?? "Unknown")"
        
        self.calculatedDutyDetails = DutyDetails(
            description: routeDescription,
            kilometers: self.calculateTotalKilometers(),
            date: Date()
            // Dacă vrei să stochezi și averageSpeed/fuelConsumption, le poți pune aici:
            // averageSpeed: self.averageSpeed,
            // fuelConsumption: <calculează ceva sau 0.0>
        )
        
        // Semnalăm ecranului MyCarView să deschidă sheet-ul de Daily Activity
        self.didEndDuty = true
        
        print("Duty ended for user: \(userId). DutyDetails pregătit local.")
    }
    
    func fetchLastLocation() {
        guard let location = currentLocation else { return }
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            DispatchQueue.main.async {
                if let placemark = placemarks?.first {
                    self?.lastLocationName = placemark.name ?? placemark.locality ?? "Unknown"
                } else {
                    self?.lastLocationName = "Unknown"
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.currentLocation = loc
            if self.isDutyActive {
                self.locations.append(loc)
                self.averageSpeed = self.calculateAverageSpeed()
                
                // Trimitem live location la backend la fiecare 5 secunde (exemplu)
                if self.lastLiveUpdate == nil || Date().timeIntervalSince(self.lastLiveUpdate!) >= 5 {
                    DutyTrackingService.shared.sendLiveLocation(
                        location: loc,
                        averageSpeed: self.averageSpeed,
                        userId: self.userId
                    )
                    self.lastLiveUpdate = Date()
                }
            }
            self.fetchLastLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    private func calculateAverageSpeed() -> Double {
        guard locations.count > 1 else { return 0.0 }
        let speeds = locations.dropFirst().enumerated().map { (index, location) in
            let previous = locations[index]
            let distance = location.distance(from: previous)
            let time = location.timestamp.timeIntervalSince(previous.timestamp)
            return time > 0 ? (distance / time) * 3.6 : 0.0 // m/s -> km/h
        }
        return speeds.reduce(0.0, +) / Double(speeds.count)
    }
    
    private func calculateTotalKilometers() -> Double {
        guard locations.count > 1 else { return 0.0 }
        return locations.enumerated().dropFirst().reduce(0.0) {
            $0 + $1.element.distance(from: locations[$1.offset - 1])
        } / 1000.0
    }
}

struct DutyDetails {
    let description: String
    let kilometers: Double
    let date: Date
    
    // Dacă vrei să stochezi și altele, adaugă aici:
    // let averageSpeed: Double
    // let fuelConsumption: Double
}
