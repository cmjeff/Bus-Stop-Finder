//
//  BusStopModel.swift
//  Bus Stop Finder
//
//  Created by jeff wong on 2023-01-27.
//

import Foundation
import CoreLocation

struct BusStopModel: Codable  {
    let Stops: [BusStopModel]?
    let Stop: String?
    let StopNo: Int
    let Name: String
    let BayNo: String
    let City: String
    let OnStreet: String
    let AtStreet: String
    let Latitude: Double
    let Longitude: Double
    let WheelchairAccess: Int
    let Distance: Float
    let Routes: String
}
