//
//  GoogleMapsView.swift
//  GestFront
//
//  Created by Fabian Andrei Hirjan on 21.03.2025.
//


import SwiftUI
import GoogleMaps

struct GoogleMapsView: UIViewRepresentable {
    @Binding var currentLocation: CLLocation?
    @Binding var path: GMSMutablePath

    func makeUIView(context: Context) -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: currentLocation?.coordinate.latitude ?? 0,
                                              longitude: currentLocation?.coordinate.longitude ?? 0,
                                              zoom: 16)
        let mapView = GMSMapView(frame: .zero, camera: camera)
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        return mapView
    }

    func updateUIView(_ mapView: GMSMapView, context: Context) {
        if let loc = currentLocation {
            let cameraUpdate = GMSCameraUpdate.setTarget(loc.coordinate, zoom: 16)
            mapView.animate(with: cameraUpdate)

            path.add(loc.coordinate)
            mapView.clear()
            let polyline = GMSPolyline(path: path)
            polyline.strokeWidth = 4
            polyline.strokeColor = .blue
            polyline.map = mapView
        }
    }
}
