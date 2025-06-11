import Foundation
import CoreLocation
import SwiftUI
import GoogleMaps

class DutyTrackingViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = DutyTrackingViewModel()
    
    @Published var isDutyActive: Bool = false
    @Published var currentLocation: CLLocation?
    @Published var lastLocationName: String?
    @Published var averageSpeed: Double = 0.0
    @Published var currentSpeed: Double = 0.0
    @Published var dutyStartTime: Date?
    @Published var speedLimit: Double = 50.0
    @Published var didEndDuty: Bool = false
    @Published var calculatedDutyDetails: DutyDetails?
    
    // Add task-related properties
    @Published var currentTask: Task?
    @Published var destinationCoordinate: CLLocationCoordinate2D?
    
    private let locationManager = CLLocationManager()
    private var locations: [CLLocation] = []
    private var lastLiveUpdate: Date?
    private let userId: String
    private let geocoder = CLGeocoder()
    private let networkManager = NetworkManager.shared
    
    private override init() {
        self.userId = UserDefaults.standard.string(forKey: "user_id") ?? "unknown_user"
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
    }
    
    // Set the current task and geocode its destination
    func setCurrentTask(_ task: Task) {
        self.currentTask = task
        geocodeDestination(task.destination)
    }
    
    // Geocode destination string to coordinates
    private func geocodeDestination(_ destination: String) {
        geocoder.geocodeAddressString(destination) { [weak self] placemarks, error in
            if let error = error {
                print("Geocoding error for destination '\(destination)': \(error.localizedDescription)")
                return
            }
            if let coordinate = placemarks?.first?.location?.coordinate {
                DispatchQueue.main.async {
                    self?.destinationCoordinate = coordinate
                    print("Destination '\(destination)' geocoded to: \(coordinate.latitude), \(coordinate.longitude)")
                }
            }
        }
    }
    
    // Mark checkpoint by updating task status to COMPLETED
    func markCheckpoint(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let task = currentTask,
              let urlComponents = URLComponents(string: "\(Config.baseURL)/tasks/\(task.id)/status"),
              let token = UserDefaults.standard.string(forKey: "jwt_token") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No task or invalid URL/token"])))
            return
        }
        
        var components = urlComponents
        components.queryItems = [URLQueryItem(name: "userId", value: userId)]
        let body: [String: Any] = ["status": "COMPLETED"]
        
        guard let url = components.url else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to construct URL"])))
            return
        }
        
        let request = networkManager.createRequest(url: url, method: "PUT", body: body, token: token)
        networkManager.performVoidRequest(request) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.currentTask = nil
                    self?.destinationCoordinate = nil
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func startDuty(task: Task? = nil) {
        guard !isDutyActive else { return }
        if let task = task {
            setCurrentTask(task)
        }
        locationManager.startUpdatingLocation()
        isDutyActive = true
        dutyStartTime = Date()
        locations.removeAll()
        averageSpeed = 0.0
        currentSpeed = 0.0
        speedLimit = 50.0
        didEndDuty = false
        calculatedDutyDetails = nil
        print("Duty started for user: \(userId)")
    }
    
    func stopDuty() {
        guard isDutyActive else { return }
        locationManager.stopUpdatingLocation()
        isDutyActive = false
        dutyStartTime = nil
        speedLimit = 50.0
        
        let routeDescription = currentTask.map { "Duty from \($0.startingPoint) to \($0.destination)" } ?? "Duty from \(lastLocationName ?? "Unknown")"
        
        self.calculatedDutyDetails = DutyDetails(
            description: routeDescription,
            kilometers: self.calculateTotalKilometers(),
            date: Date()
        )
        
        self.didEndDuty = true
        print("Duty ended for user: \(userId). DutyDetails prepared.")
    }
    
    // Rest of the methods (fetchLastLocation, locationManager, etc.) remain unchanged
    func fetchLastLocation() {
        guard let location = currentLocation else { return }
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let placemark = placemarks?.first {
                    self.lastLocationName = placemark.name ?? placemark.locality ?? "Unknown"
                    self.speedLimit = self.estimateSpeedLimit(from: placemark)
                } else {
                    self.lastLocationName = "Unknown"
                    self.speedLimit = 50.0
                }
            }
        }
    }
    
    private func estimateSpeedLimit(from placemark: CLPlacemark) -> Double {
        if let locality = placemark.locality, placemark.thoroughfare != nil {
            if placemark.subLocality?.lowercased().contains("highway") ?? false {
                return 90.0
            } else if placemark.locality != nil {
                return 50.0
            }
        }
        return 50.0
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.currentLocation = loc
            self.currentSpeed = max(loc.speed * 3.6, 0)
            if self.isDutyActive {
                self.locations.append(loc)
                self.averageSpeed = self.calculateAverageSpeed()
                
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
            return time > 0 ? (distance / time) * 3.6 : 0.0
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
}
