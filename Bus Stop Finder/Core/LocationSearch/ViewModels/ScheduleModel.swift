//
//  ScheduleModel.swift
//  Bus Stop Finder
//
//  Created by jeff wong on 2023-01-27.
//

import Foundation

struct ScheduleModel: Codable {
    let Pattern: String
    let Destination: String
    let ExpectedLeaveTime: String
    let ExpectedCountdown:Int
    let ScheduleStatus: String
    let CancelledStop: Bool
    let AddedTrip: Bool
    let AddedStop: Bool
    let LastUpdate: String
}
