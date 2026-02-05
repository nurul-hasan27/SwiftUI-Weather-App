//
//  ContentView.swift
//  SwiftUI-Weather
//
//  Created by Nurul Hasan on 04/02/26.
//

import SwiftUI
import Combine

enum City: CaseIterable, Identifiable {

    case muzaffarpur
    case delhi
    case mumbai
    case bhubaneshwar

    var id: String { name }

    var name: String {
        switch self {
        case .muzaffarpur: return "Muzaffarpur"
        case .delhi: return "Delhi"
        case .mumbai: return "Mumbai"
        case .bhubaneshwar: return "Bhubaneswar"
        }
    }

    var latitude: Double {
        switch self {
        case .muzaffarpur: return 26.1197
        case .delhi: return 28.6139
        case .mumbai: return 19.0760
        case .bhubaneshwar: return 20.2961
        }
    }

    var longitude: Double {
        switch self {
        case .muzaffarpur: return 85.3910
        case .delhi: return 77.2090
        case .mumbai: return 72.8777
        case .bhubaneshwar: return 85.8245
        }
    }
}


struct WeatherResponse: Decodable {
    let main: Main
    let weather: [Weather]
}

struct Main: Decodable {
    let temp: Double
}

struct Weather: Decodable {
    let icon: String
}

struct ForecastResponse: Decodable {
    let list: [ForecastItem]
}

struct ForecastItem: Decodable, Identifiable {
    let dt: TimeInterval
    let main: Main
    let weather: [Weather]

    var id: TimeInterval { dt }
}


class WeatherViewModel: ObservableObject {

    @Published var cityName: String = "City"
    @Published var temperature: Int = 0
    @Published var icon: String = "cloud.sun.fill"
    @Published var forecast: [ForecastItem] = []


    func fetchWeather(for city: City) {

        let apiKey = "Enter_your_Open_Weather_API_key_here"

        
        // -------- today 's forecast ----------
        let urlString =
        "https://api.openweathermap.org/data/2.5/weather?lat=\(city.latitude)&lon=\(city.longitude)&units=metric&appid=\(apiKey)"

        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in

            guard let data else { return }

            let decoded = try? JSONDecoder().decode(WeatherResponse.self, from: data)

            guard let decoded else { return }

            Task { @MainActor in
                self.cityName = city.name
                self.temperature = Int(decoded.main.temp)
                self.icon = self.mapIcon(decoded.weather.first?.icon ?? "")
            }

        }.resume()
        
        // -------- next 5 day 's forecast ----------
        let forecastUrl =
        "https://api.openweathermap.org/data/2.5/forecast?lat=\(city.latitude)&lon=\(city.longitude)&units=metric&appid=\(apiKey)"

        guard let forecastURL = URL(string: forecastUrl) else { return }

        URLSession.shared.dataTask(with: forecastURL) { data, _, _ in
            guard let data else { return }
            let decoded = try? JSONDecoder().decode(ForecastResponse.self, from: data)
            guard let decoded else { return }

            let grouped = Dictionary(grouping: decoded.list) { item in
                Calendar.current.startOfDay(
                    for: Date(timeIntervalSince1970: item.dt)
                )
            }

            let daily = grouped
                .sorted { $0.key < $1.key }
                .dropFirst()
                .prefix(5)
                .map { $0.value.first! }

            Task { @MainActor in
                self.forecast = daily
            }
        }.resume()
    }

     func mapIcon(_ code: String) -> String {
        switch code {
        case "01d": return "sun.max.fill"
        case "01n": return "moon.stars.fill"
        case "02d": return "cloud.sun.fill"
        case "09d", "10d": return "cloud.rain.fill"
        case "11d": return "cloud.bolt.fill"
        case "13d": return "snow"
        default: return "cloud.fill"
        }
    }
}


struct ContentView: View {

    @State private var selectedCity: City = .muzaffarpur
    @State private var showCityPicker = false
    @State private var isNightMode = false

    @StateObject private var weatherVM = WeatherViewModel()

    var body: some View {
        ZStack {
            BackgroundView(isNight: $isNightMode, topColor: .blue, bottomColor: Color("lightBlue"))

            VStack(spacing: 20) {

                MenuView(selectedCity: $selectedCity, weatherVM: weatherVM)

                Image(systemName: weatherVM.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .foregroundColor(.white)

                Text("\(weatherVM.temperature)°C")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(.white)

                Spacer()
                
                ForecastRowView(weatherVM:  weatherVM)
                
                Spacer()
                
                Button{
                    print("clicked")
                    isNightMode.toggle()
                }label: {
                    WeatherButtonView(buttonLabel: isNightMode ? "Day Mode" : "Night Mode", textColor: .blue, backgroundColor: .white)
                }
                Spacer()
            }
        }
        .onAppear {
            // initial API call
            weatherVM.fetchWeather(for: selectedCity)
        }
    }
}

struct BackgroundView : View {

    @Binding var isNight : Bool

    var topColor : Color
    var bottomColor : Color

    var body: some View {
        LinearGradient(colors: [isNight ? .black : topColor, isNight ? .gray : bottomColor],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
    }
}

struct MenuView : View {
    
    @Binding var selectedCity: City
    @ObservedObject var weatherVM: WeatherViewModel
    
    var body : some View {
        Menu {
            ForEach(City.allCases) { city in
                Button {
                    selectedCity = city
                    weatherVM.fetchWeather(for: city)
                } label: {
                    Text(city.name)
                }
            }
        } label: {
            HStack(spacing: 6) {
                Text(weatherVM.cityName.isEmpty ? selectedCity.name : weatherVM.cityName)
                    .font(.largeTitle)
                    .foregroundColor(.white)

                Image(systemName: "chevron.down")
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
    }
}

struct ForecastRowView: View {

    @ObservedObject var weatherVM: WeatherViewModel

    var body: some View {
        HStack(spacing: 25) {
            ForEach(weatherVM.forecast) { day in
                VStack(spacing:10) {
                    Text(
                        Date(timeIntervalSince1970: day.dt),
                        format: .dateTime.weekday(.abbreviated)
                    )

                    Image(systemName: weatherVM.mapIcon(day.weather.first?.icon ?? ""))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .foregroundColor(.white)

                    Text("\(Int(day.main.temp))°C")
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .medium, design: .default))
                }
            }
        }
    }
}


#Preview {
    ContentView()
}
