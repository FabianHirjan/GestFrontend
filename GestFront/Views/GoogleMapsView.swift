import SwiftUI
import GoogleMaps

struct GoogleMapsView: UIViewRepresentable {
    @Binding var currentLocation: CLLocation?
    @Binding var path: GMSMutablePath
    var destinationCoordinate: CLLocationCoordinate2D?
    
    func makeUIView(context: Context) -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 15)
        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        mapView.isMyLocationEnabled = true
        return mapView
    }
    
    func updateUIView(_ mapView: GMSMapView, context: Context) {
        if let location = currentLocation {
            let coordinate = location.coordinate
            mapView.animate(toLocation: coordinate)
            
            path.add(coordinate)
            let polyline = GMSPolyline(path: path)
            polyline.strokeColor = .blue
            polyline.strokeWidth = 5
            polyline.map = mapView
            
            // Add marker for current location
            let currentMarker = GMSMarker(position: coordinate)
            currentMarker.title = "Current Location"
            currentMarker.map = mapView
        }
        
        // Add marker for destination
        if let dest = destinationCoordinate {
            let marker = GMSMarker(position: dest)
            marker.title = "Destination"
            marker.icon = GMSMarker.markerImage(with: .red)
            marker.map = mapView
        }
    }
}
