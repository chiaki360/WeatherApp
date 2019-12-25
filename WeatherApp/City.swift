//
//  City.swift
//  WeatherApp
//
//  Created by Shaiful Nizam on 2019/10/18.
//  Copyright © 2019 Chiaki Yuge. All rights reserved.
//

import Foundation

// City object
struct City: Codable {
    var id: Int
    var name: String
    var country: String
    var coord: Coord
}

struct Coord: Codable {
    var lon: Float
    var lat: Float
}
