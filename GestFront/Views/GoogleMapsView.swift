//
//  GoogleMapsView.swift
//  GestFront
//

import SwiftUI
import GoogleMaps

struct GoogleMapsView: UIViewRepresentable {
    @Binding var currentLocation: CLLocation?
    @Binding var path: GMSMutablePath
    
    func makeUIView(context: Context) -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: 47.158, longitude: 27.619, zoom: 15)
        let mapView = GMSMapView(frame: .zero, camera: camera)
        mapView.isMyLocationEnabled = true
        return mapView
    }
    
    func updateUIView(_ mapView: GMSMapView, context: Context) {
        mapView.clear()
        
        if let location = currentLocation {
            let coordinate = location.coordinate
            path.add(coordinate)
            
            let marker = GMSMarker()
            marker.position = coordinate
            marker.title = "Current Location"
            marker.map = mapView
            
            let polyline = GMSPolyline(path: path)
            polyline.strokeColor = .blue
            polyline.strokeWidth = 5.0
            polyline.map = mapView
            
            let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 15)
            mapView.animate(to: camera)
        }
    }
}
