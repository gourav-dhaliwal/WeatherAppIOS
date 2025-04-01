//
//  CitiesView.swift
//  WeatherApp
//
//  Created by Gouravdeep Singh on 2025-03-31.
//

import SwiftUI

struct CitiesView: View {
    @ObservedObject var weatherVM: WeatherViewModel
    @Binding var showTemperatureInCelsius: Bool
    
    var body: some View {
        ZStack {
            // Background gradient to match main screen
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.blue.opacity(0.4)]),
                          startPoint: .top,
                          endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            // City silhouette at bottom
            VStack {
                Spacer()
                Image(systemName: "building.2")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.blue.opacity(0.1))
                    .frame(height: 100)
                    .padding(.bottom, -20)
            }
            .edgesIgnoringSafeArea(.bottom)
            
            VStack {
                if weatherVM.savedCities.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "location.slash.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue.opacity(0.6))
                        
                        Text("No saved cities")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                        
                        Text("Search for a city to add it to your list")
                            .font(.subheadline)
                            .foregroundColor(.blue.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white.opacity(0.5))
                    )
                    .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(weatherVM.savedCities, id: \.location.name) { weather in
                                HStack(spacing: 16) {
                                    // Weather icon
                                    Image(systemName: getWeatherIcon(for: weather.current.condition.code))
                                        .symbolRenderingMode(.multicolor)
                                        .font(.system(size: 36))
                                        .frame(width: 50)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        // City name
                                        Text(weather.location.name)
                                            .font(.headline)
                                            .foregroundColor(.blue)
                                        
                                        // Weather condition
                                        Text(weather.current.condition.text)
                                            .font(.subheadline)
                                            .foregroundColor(.blue.opacity(0.7))
                                    }
                                    
                                    Spacer()
                                    
                                    // Temperature
                                    if weather.current.temp_c.isNaN {
                                        Text("--°")
                                            .font(.title)
                                            .fontWeight(.medium)
                                            .foregroundColor(.blue)
                                    } else {
                                        Text(showTemperatureInCelsius ?
                                             "\(weather.current.temp_c, specifier: "%.1f")°" :
                                             "\(weather.current.temp_c * 9/5 + 32, specifier: "%.1f")°")
                                            .font(.title)
                                            .fontWeight(.medium)
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.5))
                                )
                                .padding(.horizontal)
                                // Swipe to delete functionality
                                .contextMenu {
                                    Button(role: .destructive) {
                                        if let index = weatherVM.savedCities.firstIndex(where: { $0.location.name == weather.location.name }) {
                                            weatherVM.savedCities.remove(at: index)
                                        }
                                    } label: {
                                        Label("Remove", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding(.top)
                    }
                }
            }
        }
        .navigationTitle("Saved Cities")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !weatherVM.savedCities.isEmpty {
                EditButton()
                    .foregroundColor(.blue)
            }
        }
    }
    
    func getWeatherIcon(for code: Int) -> String {
        switch code {
            case 1000: return "sun.max.fill"
            case 1003: return "cloud.sun.fill"
            case 1006, 1009: return "cloud.fill"
            case 1030, 1135: return "cloud.fog.fill"
            case 1063, 1180, 1186, 1192: return "cloud.rain.fill"
            case 1066, 1114, 1210: return "cloud.snow.fill"
            case 1087, 1273, 1276: return "cloud.bolt.fill"
            default: return "questionmark.circle.fill"
        }
    }
}
