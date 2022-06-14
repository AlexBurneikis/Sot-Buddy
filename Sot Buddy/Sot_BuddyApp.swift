//
//  Sot_BuddyApp.swift
//  Sot Buddy
//
//  Created by Alexander Burneikis on 10/6/2022.
//

import SwiftUI

@main
struct Sot_BuddyApp: App {
    struct voyage: Identifiable, Encodable, Decodable {
        let name: String
        let duration: Int
        let gold: Int
        let doubloons: Int
        var id: String { name }
    }
    
    let placeholderData: [voyage] = []
    
    init() {
        do {
            let encoder = JSONEncoder()
            let Data = try encoder.encode(placeholderData)
            UserDefaults.standard.register(defaults: ["voyages" : Data])
        } catch {
            print("Unable to encode outputVoyage")
        }
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
