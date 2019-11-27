//
//  Weather.swift
//  WeatherApp
//
//  Created by Chiaki Yuge on 2019/11/06.
//  Copyright © 2019 Chiaki Yuge. All rights reserved.
//

import Foundation

struct CurrentWeather: Codable {
    var weather: [Weather]
    var main: Main
}

struct Weather: Codable {
    var id: Int
    var main: String
    var description: String
    var icon: String
}

struct Main: Codable {
    var temp: Float
    var pressure: Int
    var humidity: Int
    var temp_min: Float
    var temp_max: Float
}

struct HourlyWeather: Codable {
    var list: [List]
    
}

struct List: Codable {
    var dt: Int
    var main: Main
    var weather: [Weather]
    var wind: Wind
}

struct Wind: Codable {
    var speed: Float
    var deg: Float
}
