//
//  CarDTO.swift
//  GestFront
//
//  Created by Fabian Andrei Hirjan on 21.03.2025.
//


// Models/CarDTO.swift

import Foundation

struct CarDTO: Codable {
    let id: Int
    let licensePlate: String
    let mileage: Int
    let vin: String
    let lastInspection: String?
    let lastOilChange: String?
    let lastTireChange: String?
    let insuranceExpiration: String

    // make și model, venite de la carMake și carModel
    let carMake: CarMakeModelDTO
    let carModel: CarMakeModelDTO
    
    // Dacă primești datele sub altă formă (ex. LocalDateTime), 
    // fie le convertești la String, fie folosești un custom decoder.
}
