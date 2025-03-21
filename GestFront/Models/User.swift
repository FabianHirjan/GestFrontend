//
//  User.swift
//  GestFront
//
//  Created by Fabian Andrei Hirjan on 21.03.2025.
//


// Models/User.swift

import Foundation

struct User: Codable {
    let username: String
    let role: String
    let email: String
    let firstName: String?
    let lastName: String?
    // ... orice altceva mai ai nevoie
    
    // Poți adăuga un initializer, dar dacă toate sunt opționale
    // sau mapezi direct prin JSON, e suficient să fie decodabil (Codable).
}
