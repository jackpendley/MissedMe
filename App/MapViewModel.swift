//
//  LocationService.swift
//  App
//
//  Created by Daniel Fichtl on 2/1/23.
//

import MapKit
import _MapKit_SwiftUI
import CoreLocation

// rank people by how long you were next to them / how close you were to them.
// if you guys are friends, don't show up on their feed.

final class MapViewModel : NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 42.27635, longitude: -83.73637),
        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
    
    @Published var mapView = MKMapView()
    
    var locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func checkLocationAutorization () {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("Location Services are restricted. Go into settings to change permissions.")
        case .denied:
            print("Location Services were denied. Go into settings to change permissions.")
        case .authorizedAlways, .authorizedWhenInUse:
            updateRegionLocation()
            locationManager.startUpdatingLocation()
        @unknown default:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAutorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.last?.coordinate else { return }
        region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
        mapView.setCenter(userLocation, animated: true)
        mapView.region = region
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error getting user location: \(error.localizedDescription)")
    }
    
    func updateRegionLocation() {
        guard let coord = locationManager.location?.coordinate else { return }
        region = MKCoordinateRegion(
            center: coord,
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
        mapView.setCenter(coord, animated: true)
        mapView.region = region
    }
}

