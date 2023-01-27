//
//  BusTimeModel.swift
//  Bus Stop Finder
//
//  Created by jeff wong on 2023-01-27.
//

import Foundation

struct BusTimeModel: Codable{
    let NextBuses: String?
    let NextBus: String?
    let RouteNo: String
    let RouteName: String
    let Direction: String
    let Schedules: [ScheduleModel]
}
