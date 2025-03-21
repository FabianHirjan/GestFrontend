//
//  DailyActivityDTO.swift
//  GestFront
//
//  Created by Fabian Andrei Hirjan on 21.03.2025.
//


// Models/DailyActivityDTO.swift

import Foundation

struct DailyActivityDTO: Codable {
    let id: Int
    let description: String
    let kilometers: Int
    let fuelConsumption: Double
    let approved: Bool
    let date: String
    // Dacă endpoint-ul îți trimite data ca string (ex. "2025-03-10"),
    // e suficient să o stochezi tot ca string sau să faci un parsing ulterior.
}
