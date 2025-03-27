//
//  CarDTO.swift
//  GestFront
//
//  Created by Fabian Andrei Hirjan on 21.03.2025.
//

import Foundation

struct CarDTO: Codable, Identifiable {
    let id: Int64
    let licensePlate: String
    let mileage: Int64 
    let vin: String
    let lastInspection: String?
    let lastOilChange: String?
    let lastTireChange: String?
    let insuranceExpiration: String
    let carMake: CarMakeDTO
    let carModel: CarModelDTO
    let driver: UserDTO?
}


