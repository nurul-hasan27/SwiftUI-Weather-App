//
//  ContentView.swift
//  SwiftUI-Weather
//
//  Created by Nurul Hasan on 04/02/26.
//

import SwiftUI

struct ContentView: View {
    
    @State private var isNightMode = false
    
    enum WeekDay: CaseIterable {
        case tue, wed, thu, fri, sat

        var title: String {
            switch self {
            case .tue: return "TUE"
            case .wed: return "WED"
            case .thu: return "THU"
            case .fri: return "FRI"
            case .sat: return "SAT"
            }
        }

        var temperature: Int {
            switch self {
            case .tue: return 79
            case .wed: return 59
            case .thu: return 89
            case .fri: return 29
            case .sat: return 19
            }
        }

        var icon: String {
            switch self {
            case .tue: return "cloud.sun.fill"
            case .wed: return "cloud.rain.fill"
            case .thu: return "cloud.bolt.rain.fill"
            case .fri: return "cloud.sun.rain.fill"
            case .sat: return "snowflake"
            }
        }
    }

    
    var body: some View {
        ZStack{
            BackgroundView(isNight: $isNightMode, topColor: .blue, bottomColor: Color("lightBlue"))
            
            VStack{
                CityNameView(cityName: "Muzaffarpur")
                
                MainWeatherStatusView(imageName:isNightMode ? "moon.stars.fill" : "cloud.sun.fill", temp: 70)
                
                Spacer()
                
                HStack(spacing:20){
                    HStack(spacing: 20) {
                        ForEach(WeekDay.allCases, id: \.self) { day in
                            WeatherDayView(
                                dayOfWeek: day.title,
                                temperature: day.temperature,
                                weatherIcon: day.icon
                            )
                        }
                    }
                }
                
                Spacer()
                Button{
                    print("clicked")
                    isNightMode.toggle()
                }label: {
                    WeatherButtonView(buttonLabel: "Change Day Time", textColor: .blue, backgroundColor: .white)
                }
                Spacer()
            }
            
        }
//        HStack{
//            Text("the placeholder text")
//            VStack {
//                Image(systemName: "globe")
//                    .imageScale(.large)
//                    .foregroundStyle(.tint)
//                Text("are are are.. hosh me madhaw..!")
//                Button("hello") {
//                    print("hi")
//                }
//            }
//            .padding()
//        }
    }
}

struct WeatherDayView : View {
    var dayOfWeek : String
    var temperature : Int
    var weatherIcon : String
    
    var body: some View {
        VStack{
            Text(dayOfWeek)
                .font(.system(size: 16, weight: .medium, design: .default))
                .foregroundStyle(Color(.white))
            
            Image(systemName: weatherIcon)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
            
            Text("\(temperature)°")
                .font(.system(size: 28, weight: .medium, design: .default))
                .foregroundStyle(Color(.white))
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

struct CityNameView : View {
    var cityName : String
    var body : some View {
        Text(cityName)
            .font(.system(size: 32, weight: .bold, design: .default))
            .foregroundStyle(Color(.white))
            .padding()
    }
}

struct MainWeatherStatusView : View {
    
    var imageName : String
    var temp : Int
    
    var body : some View {
        VStack(spacing: 5){
            Image(systemName: imageName)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
            
            Text("\(temp)°")
                .font(.system(size: 70, weight: .bold, design: .default))
                .foregroundStyle(Color(.white))
        }
    }
}

#Preview {
    ContentView()
}
 
