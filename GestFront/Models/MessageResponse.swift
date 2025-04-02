//
//  MessageResponse.swift
//  GestFront
//
//  Created by Fabian Andrei Hirjan on 02.04.2025.
//


import Foundation

struct MessageResponse: Codable {
    let message: String
    let sender: UserDTO
    let receiver: UserDTO
    let sentDate: String?  // adjust type as needed
}
