//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Gouravdeep Singh on 2025-03-31.
//

import Foundation
import CoreLocation

class WeatherViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var weather: WeatherData?
    @Published var isLoading = false
    @Published var savedCities: [WeatherData] = []
    @Published var errorMessage: String?
    
    private let apiKey = "04a1296bf74a4e93a4a205625253003"
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    // MARK: - Location Methods
    func getCurrentLocationWeather() {
        let status = locationManager.authorizationStatus
        
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            errorMessage = "Location access denied. Please enable in Settings."
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        @unknown default:
            errorMessage = "Unknown location status"
        }
    }
}
