//
//  NewVoyageView.swift
//  Sot Buddy
//
//  Created by Alexander Burneikis on 14/6/2022.
//

import SwiftUI

struct NewVoyageView: View {
    @State private var voyageName = ""
    
    @State private var initialGold = ""
    @State private var initialDoubloons = ""
    @State private var finalGold = ""
    @State private var finalDoubloons = ""
    
    @State private var voyageSheetShow = false
    @State private var showAlert = false
    @State private var alertNameTaken = false
    
    @ObservedObject var timerClass = TimerClass()
    
    func timeString(time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    func goldProfit() -> Int {
        if finalGold == "" {
            return 0
        } else {
            if initialGold == "" {
                return Int(finalGold)!
            }
            return Int(finalGold)! - Int(initialGold)!
        }
    }
    
    func doubloonProfit() -> Int {
        if finalDoubloons == "" {
            return 0
        } else {
            if initialDoubloons == "" {
                return Int(finalDoubloons)!
            }
            return Int(finalDoubloons)! - Int(initialDoubloons)!
        }
    }
    
    func goldPerHour() -> Int {
        let hours = Float(timerClass.secondElapsed) / 3600
        return hours == 0 ? 0 : Int(Float(goldProfit()) / hours + (goldProfit() == 0 ? 0 : 1))
    }
    
    func doubloonsPerHour() -> Int {
        let hours = Float(timerClass.secondElapsed) / 3600
        return hours == 0 ? 0 : Int(Float(doubloonProfit()) / hours + (doubloonProfit() == 0 ? 0 : 1))
    }
    
    
    
    func saveVoyage() {
        let outputVoyage = voyage(name: (voyageName.count != 0 ? voyageName : "My Voyage"), duration: Int(timerClass.secondElapsed), gold: goldProfit(), doubloons: doubloonProfit())
        voyages.insert(outputVoyage, at: 0)
        do {
            let encoder = JSONEncoder()
            let Data = try encoder.encode(voyages)
            UserDefaults.standard.set(Data, forKey: "voyages")
        } catch {
            print("Error during encoding")
        }
    }
    
    var body: some View {
        Form {
            Section {
                TextField("My Voyage", text: $voyageName)
                HStack {
                    Image("Gold")
                    TextField("Initial Gold", text: $initialGold)
                        .keyboardType(.decimalPad)
                }
                HStack {
                    Image("Doubloon")
                    TextField("Initial Doubloons", text: $initialDoubloons)
                        .keyboardType(.decimalPad)
                }
            }
            Section {
                Button {
                    if voyages.contains(where: { voyage in
                        return voyage.name == (voyageName.count != 0 ? voyageName : "My Voyage")
                    }) {
                        alertNameTaken.toggle()
                    }
                    else {
                        voyageSheetShow.toggle()
                        timerClass.start()
                    }
                } label: {
                    HStack {
                        Spacer()
                        Text("Start")
                            .foregroundColor(.blue)
                        Spacer()
                    }
                }
            }
        }
        .alert(isPresented: $alertNameTaken) {
            Alert(
                title: Text("Name Taken"),
                dismissButton: Alert.Button.destructive(Text("Done")) {
                    voyageName = ""
                })}
        .navigationBarTitle(Text("New Voyage"))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $voyageSheetShow, onDismiss: {
            timerClass.stop()
            voyageName = ""
            initialGold = ""
            initialDoubloons = ""
            finalGold = ""
            finalDoubloons = ""
            timerClass.secondElapsed = 0.9
        }) {
            NavigationView {
                VStack {
                    Form {
                        Section {
                            HStack {
                                Spacer()
                            Text(timeString(time: TimeInterval(timerClass.secondElapsed)))
                                .font(.system(size: 60))
                                Spacer()
                            }
                        } header: {
                            Text("Duration")
                        }
                        Section {
                            HStack {
                                Image("Gold")
                                Text(initialGold.count == 0 ? "0" : initialGold)
                            }
                            HStack {
                                Image("Doubloon")
                                Text(initialDoubloons.count == 0 ? "0" : initialDoubloons)
                            }
                        } header: {
                            Text("Initial")
                        }
                        Section {
                        HStack {
                            Image("Gold")
                            TextField("Final Gold", text: $finalGold)
                                .keyboardType(.decimalPad)
                        }
                        HStack {
                            Image("Doubloon")
                            TextField("Final Doubloons", text: $finalDoubloons)
                                .keyboardType(.decimalPad)
                        }
                        } header: {
                            Text("Final")
                        }
                        Button {
                            showAlert.toggle()
                            timerClass.stop()
                        } label: {
                            HStack {
                                Spacer()
                            Text("Done")
                                .bold()
                                Spacer()
                            }
                        }
                    }
                    HStack {
                        Spacer()
                        Text("+" + String(goldProfit()))
                        Image("Gold")
                        Text(String(goldPerHour()) + "/hour")
                        Spacer()
                        Text("+" + String(doubloonProfit()))
                        Image("Doubloon")
                        Text(String(doubloonsPerHour()) + "/hour")
                        Spacer()
                    }
                }
                .navigationTitle(Text(voyageName != "" ? voyageName : "My Voyage"))
                .navigationBarTitleDisplayMode(.large)
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Done?"),
                    primaryButton: Alert.Button.destructive(Text("Done")) {
                        saveVoyage()
                        voyageSheetShow.toggle()
                    },
                    secondaryButton: Alert.Button.cancel(Text("Continue")) {
                        timerClass.start()
                    })
            }
        }
    }
}

struct NewVoyageView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
