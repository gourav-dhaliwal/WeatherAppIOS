//
//  WeatherModel.swift
//  WeatherApp
//
//  Created by Gouravdeep Singh on 2025-03-31.
//

import Foundation

struct WeatherData: Codable, Identifiable {
    var id: String { location.name }
    let location: Location
    let current: Current
}

struct Location: Codable {
    let name: String
    let region: String?
    let country: String?
}

struct Current: Codable {
    let temp_c: Double
    let temp_f: Double?
    let condition: Condition
    let wind_kph: Double?
    let humidity: Int?
    let cloud: Int?
}

struct Condition: Codable {
    let text: String
    let code: Int
}
