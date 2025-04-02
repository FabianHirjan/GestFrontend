//
//  UserDTO.swift
//  GestFront
//
//  Created by Fabian Andrei Hirjan on 27.03.2025.
//

import Foundation

struct UserDTO: Codable, Identifiable, Hashable {
    let id: Int
    let username: String
    let email: String?
    let role: String?
    let firstName: String?
    let lastName: String?
}

