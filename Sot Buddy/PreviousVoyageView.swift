//
//  PreviousVoyageView.swift
//  Sot Buddy
//
//  Created by Alexander Burneikis on 14/6/2022.
//

import SwiftUI

struct PreviousVoyageView: View {
    var previousVoyage: voyage = voyage(name: "My Voyage", duration: 0, gold: 0, doubloons: 0)
    
    func timeString(time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    func goldPerHour() -> Int {
        let hours = (Float(previousVoyage.duration)) / 3600
        return hours == 0 ? 0 : Int(Float(previousVoyage.gold) / hours + (previousVoyage.gold == 0 ? 0 : 1))
    }
    
    func doubloonsPerHour() -> Int {
        let hours = (Float(previousVoyage.duration)) / 3600
        return hours == 0 ? 0 : Int((Float(previousVoyage.doubloons)) / hours + (previousVoyage.doubloons == 0 ? 0 : 1))
    }
    
    var body: some View {
        VStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        Text(timeString(time: TimeInterval(previousVoyage.duration)))
                            .font(.system(size: 60))
                        Spacer()
                    }
                } header: {
                    Text("Duration")
                }
                Section {
                    HStack {
                        Image("Gold")
                        Text("Gold Earned:")
                        Text(String(previousVoyage.gold))
                    }
                    HStack {
                        Image("Gold")
                        Text("Gold/Hour:")
                        Text(String(goldPerHour()))
                    }
                } header: {
                    Text("Gold")
                }
                Section {
                    HStack {
                        Image("Doubloon")
                        Text("Doubloons Earned:")
                        Text(String(previousVoyage.doubloons))
                    }
                    HStack {
                        Image("Doubloon")
                        Text("Doubloons/Hour:")
                        Text(String(doubloonsPerHour()))
                    }
                } header: {
                    Text("Doubloons")
                }
            }
        }
        .navigationBarTitle(Text(previousVoyage.name))
        .navigationBarTitleDisplayMode(.large)
    }
}

struct PreviousVoyageView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
