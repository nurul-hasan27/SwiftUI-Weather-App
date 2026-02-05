//
//  WeatherButton.swift
//  SwiftUI-Weather
//
//  Created by Nurul Hasan on 05/02/26.
//

import SwiftUI

struct WeatherButtonView : View {
    
    var buttonLabel : String
    var textColor : Color
    var backgroundColor : Color
    
    var body : some View {
        Text(buttonLabel)
            .frame(width: 180, height: 50)
            .background(backgroundColor)
            .foregroundStyle(textColor)
            .font(.system(size: 20, weight: .bold, design: .default))
            .cornerRadius(15)
    }
}
