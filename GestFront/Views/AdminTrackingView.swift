//
//  AdminTrackingView.swift
//  GestFront
//
//  Created by Fabian Andrei Hirjan on 21.03.2025.
//


//
//  AdminTrackingView.swift
//  GestFront
//

import SwiftUI
import GoogleMaps

struct AdminTrackingView: View {
    @StateObject private var trackingService = RealTimeTrackingService.shared
    
    var body: some View {
        VStack {
            Text("Real-Time User Tracking")
                .font(.title)
                .padding()
            
            GoogleMapsAdminView(userLocations: $trackingService.userLocations)
                .frame(height: 400)
                .cornerRadius(12)
            
            List(trackingService.userLocations) { location in
                VStack(alignment: .leading) {
                    Text("User: \(location.username) (ID: \(location.userId))")
                        .font(.headline)
                    Text("Lat: \(String(format: "%.6f", location.latitude)), Lon: \(String(format: "%.6f", location.longitude))")
                    Text("Time: \(location.timestamp)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
        .navigationTitle("Admin Dashboard")
        .onAppear {
            trackingService.connect() // Reconnect if needed
        }
        .onDisappear {
            trackingService.disconnect()
        }
    }
}

struct GoogleMapsAdminView: UIViewRepresentable {
    @Binding var userLocations: [UserLocation]
    
    func makeUIView(context: Context) -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: 47.158, longitude: 27.619, zoom: 15) // Default to your test area
        let mapView = GMSMapView(frame: .zero, camera: camera)
        return mapView
    }
    
    func updateUIView(_ mapView: GMSMapView, context: Context) {
        mapView.clear()
        for location in userLocations {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            marker.title = location.username
            marker.snippet = "ID: \(location.userId) | \(location.timestamp)"
            marker.map = mapView
        }
        if let firstLocation = userLocations.first {
            let camera = GMSCameraPosition.camera(withLatitude: firstLocation.latitude,
                                                 longitude: firstLocation.longitude,
                                                 zoom: 15)
            mapView.animate(to: camera)
        }
    }
}
