//
//  ChatMessage.swift
//  GestFront
//
//  Created by Fabian Andrei Hirjan on 28.03.2025.
//
import Foundation

// Existing ChatMessage remains unchanged:
struct ChatMessage: Codable, Identifiable {
    let id = UUID()  // local ID, not from JSON
    let senderId: Int
    let receiverId: Int
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case senderId, receiverId, message
    }
}


