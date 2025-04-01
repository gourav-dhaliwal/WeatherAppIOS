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
    func fetchWeather(city: String) {
        guard !city.isEmpty else {
            errorMessage = "Please enter a city name"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        guard let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.weatherapi.com/v1/current.json?key=\(apiKey)&q=\(encodedCity)&aqi=no") else {
            isLoading = false
            errorMessage = "Invalid city name"
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }

            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                DispatchQueue.main.async {
                    self.errorMessage = "Weather data not found"
                }
                return
            }

            if let data = data {
                do {
                    let weatherData = try JSONDecoder().decode(WeatherData.self, from: data)
                    DispatchQueue.main.async {
                        self.weather = weatherData
                        if !self.savedCities.contains(where: { $0.location.name == weatherData.location.name }) {
                            self.savedCities.append(weatherData)
                        }
                        self.errorMessage = nil
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to decode weather data"
                    }
                }
            }
        }.resume()
    }
}
