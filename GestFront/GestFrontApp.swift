//
//  GestFrontApp.swift
//  GestFront
//
//  Created by Fabian Andrei Hirjan on 20.03.2025.
//


import SwiftUI
import GoogleMaps

@main
struct GestFrontApp: App {

    // Inițializare o singură dată folosind init()
    init() {
        GMSServices.provideAPIKey("AIzaSyAoN3dq6KaVeD7u1O8w6afKkpS4bdDWSRU")
    }

    var body: some Scene {
        WindowGroup {
            LoginView()
        }
    }
}

