//
//  CarMakeModelDTO.swift
//  GestFront
//
//  Created by Fabian Andrei Hirjan on 21.03.2025.
//


// Models/CarMakeModelDTO.swift

import Foundation

struct CarMakeModelDTO: Codable {
    let id: Int
    let make: String?    // pentru CarMakes
    let model: String?   // pentru CarModels
}
