//
//  Task.swift
//  GestFront
//
//  Created by Fabian Andrei Hirjan on 11.06.2025.
//


import Foundation

struct Task: Codable, Identifiable {
    let id: Int64
    let startingPoint: String
    let destination: String
    let description: String?
    let status: String
    let assignedTo: Int
    let assignedBy: Int
    let priority: String
    let dueDate: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case startingPoint
        case destination
        case description
        case status
        case assignedTo
        case assignedBy
        case priority
        case dueDate
        case createdAt
    }
}
