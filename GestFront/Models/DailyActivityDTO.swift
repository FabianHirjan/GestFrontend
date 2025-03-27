//
//  DailyActivityDTO.swift
//  GestFront
//
//  Created by Fabian Andrei Hirjan on 21.03.2025.
//


// Models/DailyActivityDTO.swift

import Foundation

struct DailyActivityDTO: Codable, Identifiable {
    let id: Int
    let description: String
    let kilometers: Double
    let date: String
    let fuelConsumption: Double?
}
