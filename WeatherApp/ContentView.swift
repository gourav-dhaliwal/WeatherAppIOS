//
//  ContentView.swift
//  WeatherApp
//
//  Created by Gouravdeep Singh on 2025-03-31.
//

import SwiftUI

struct ContentView: View {
    @StateObject var weatherVM = WeatherViewModel()
    @State private var city = ""
    @State private var showTemperatureInCelsius = true
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.blue.opacity(0.4)]),
                              startPoint: .top,
                              endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
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
                
                VStack(spacing: 20) {
                    HStack {
                        Button(action: {
                            weatherVM.getCurrentLocationWeather()
                        }) {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Image(systemName: "location.fill")
                                        .foregroundColor(.white)
                                        .font(.system(size: 18))
                                )
                        }
                        .padding(.leading, 5)
                        
                        TextField("Search Location", text: $city)
                            .padding(8)
                            .background(Color.white)
                            .cornerRadius(5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .placeholder(when: city.isEmpty) {
                                Text("Search Location").foregroundColor(.gray.opacity(0.5))
                                    .padding(.leading, 5)
                            }
                        
                        Button(action: {
                            weatherVM.fetchWeather(city: city)
                        }) {
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.blue)
                                        .font(.system(size: 18))
                                )
                        }
                        .padding(.trailing, 5)
                    }
                    .padding(.horizontal)
                    
                    NavigationLink(destination: CitiesView(weatherVM: weatherVM, showTemperatureInCelsius: $showTemperatureInCelsius)) {
                        HStack {
                            Text("Cities")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .bold()
                            
                            Spacer()
                            
                            if let weather = weatherVM.weather {
                                Text(weather.current.condition.text)
                                    .foregroundColor(.blue)
                            } else {
                                Text("Partly cloudy")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    if let weather = weatherVM.weather {
                        Image(systemName: getWeatherIcon(for: weather.current.condition.code))
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 150, height: 150)
                    } else {
                        Image(systemName: "cloud.sun.fill")
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 150, height: 150)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 0) {
                        if let weather = weatherVM.weather {
                            Text(showTemperatureInCelsius ?
                                 "\(weather.current.temp_c, specifier: "%.1f")" :
                                 "\(weather.current.temp_c * 9/5 + 32, specifier: "%.1f")")
                                .font(.system(size: 80, weight: .thin))
                                .foregroundColor(.blue)
                        } else {
                            Text("18.0")
                                .font(.system(size: 80, weight: .thin))
                                .foregroundColor(.blue)
                        }
                        
                        HStack(spacing: 0) {
                            Button(action: {
                                showTemperatureInCelsius = false
                            }) {
                                Text("F")
                                    .frame(width: 30, height: 30)
                                    .background(!showTemperatureInCelsius ? Color.blue : Color.blue.opacity(0.2))
                                    .foregroundColor(!showTemperatureInCelsius ? .white : .blue)
                                    .cornerRadius(5)
                            }
                            
                            Button(action: {
                                showTemperatureInCelsius = true
                            }) {
                                Text("C")
                                    .frame(width: 30, height: 30)
                                    .background(showTemperatureInCelsius ? Color.blue : Color.blue.opacity(0.2))
                                    .foregroundColor(showTemperatureInCelsius ? .white : .blue)
                                    .cornerRadius(5)
                            }
                        }
                        .padding(.top, 5)
                    }
                    
                    if let weather = weatherVM.weather {
                        Text(weather.location.name)
                            .font(.title)
                            .foregroundColor(.blue)
                            .padding(.top, 10)
                    } else {
                        Text("London")
                            .font(.title)
                            .foregroundColor(.blue)
                            .padding(.top, 10)
                    }
                    
                    Spacer()
                }
                .padding(.top, 50)
                
                if weatherVM.isLoading {
                    ProgressView()
                        .scaleEffect(2)
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                }
                
                // Error message display
                if let error = weatherVM.errorMessage {
                    VStack {
                        Spacer()
                        Text(error)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(10)
                            .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            if city.isEmpty {
                city = "London"
                weatherVM.fetchWeather(city: city)
            }
        }
    }
    
    func getWeatherIcon(for code: Int) -> String {
        switch code {
            case 1000: return "sun.max.fill" // Sunny
            case 1003: return "cloud.sun.fill" // Partly cloudy
            case 1006, 1009: return "cloud.fill" // Cloudy
            case 1030, 1135: return "cloud.fog.fill" // Fog
            case 1063, 1180, 1186, 1192: return "cloud.rain.fill" // Rain
            case 1066, 1114, 1210: return "cloud.snow.fill" // Snow
            case 1087, 1273, 1276: return "cloud.bolt.fill" // Thunder
            default: return "questionmark.circle.fill"
        }
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
            
            ZStack(alignment: alignment) {
                placeholder().opacity(shouldShow ? 1 : 0)
                self
            }
        }
}
