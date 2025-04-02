//
//  ValidateResponse.swift
//  GestFront
//
//  Created by Fabian Andrei Hirjan on 27.03.2025.
//


struct LoginResponse: Decodable {
    let userId: Int
    let token: String
    let role: String
}

struct ValidateResponse: Codable {
    let username: String
    let role: String
    let userId: Int  // sau String, depinde cum e pe server
}
