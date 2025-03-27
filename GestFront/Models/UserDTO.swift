//
//  UserDTO.swift
//  GestFront
//
//  Created by Fabian Andrei Hirjan on 27.03.2025.
//

struct UserDTO: Codable {
    let id: Int64
    let username: String
    let password: String?
    let role: String?
    let email: String?
    let firstName: String?
    let lastName: String?
}
