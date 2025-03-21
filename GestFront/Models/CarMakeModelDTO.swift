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
    
    // Observă că, la un moment dat, CarMakes are un field "make",
    // iar CarModels are un field "model". 
    // Poți folosi un singur DTO dacă endpoint-ul îți trimite fix ce ai nevoie. 
    // Sau poți crea două struct-uri diferite, "MakeDTO" și "ModelDTO".
}
