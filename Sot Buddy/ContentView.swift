//
//  ContentView.swift
//  Sot Buddy
//
//  Created by Alexander Burneikis on 10/6/2022.
//

import SwiftUI

private struct voyage: Identifiable {
    let id: String
    let duration: Int
}

private let voyages: [voyage] = [
    voyage(id: "My Voyage", duration: 455),
    voyage(id: "Poggy", duration: 32222),
    voyage(id: "Hello World", duration: 33),
    voyage(id: "Reaper Shenanigans", duration: 587),
    voyage(id: "Cargo", duration: 6000)
]

struct ContentView: View {
    func timeString(time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section {
                        NavigationLink {
                            NewVoyage()
                        } label: {
                            Label {
                                Text("New Voyage")
                            } icon: {
                                Image(systemName: "plus")
                            }
                            .foregroundColor(.blue)
                        }
                        
                    }
                    Section {
                        ForEach(voyages) { voyage in
                            NavigationLink(destination: {
                                PreviousVoyage()
                            }, label: {
                                HStack {
                                    Text(voyage.id)
                                    Spacer()
                                    Text(timeString(time: TimeInterval(voyage.duration)))
                                        .fontWeight(.light)
                                }
                            })
                        }
                    }
                }
            }
            .navigationBarTitle(Text("Ahoy!"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    struct NewVoyage: View {
        @State private var voyageName = ""
        @State private var initialGold = ""
        @State private var initialDoubloons = ""
        @State private var voyageSheetShow = false
        @State private var showAlert = false
        @State private var finalGold = ""
        @State private var finalDoubloons = ""
        
        @ObservedObject var managerClass = ManagerClass()
        
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
        
        func goldPerHour() -> Int {
            let hours = Float(managerClass.secondElapsed + 0.1) / 3600
            return hours == 0 ? 0 : Int(Float(goldProfit())/hours)
        }
        
        func doubloonsPerHour() -> Int {
            let hours = Float(managerClass.secondElapsed + 0.1) / 3600
            return hours == 0 ? 0 : Int(Float(doubloonProfit())/hours)
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
        
        var body: some View {
            Form {
                Section {
                    TextField("My Voyage", text: $voyageName)
                    TextField("Initial Gold", text: $initialGold)
                        .keyboardType(.decimalPad)
                    TextField("Initial Doubloons", text: $initialDoubloons)
                        .keyboardType(.decimalPad)
                }
                Section {
                    Button {
                        voyageSheetShow.toggle()
                        managerClass.start()
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
            .navigationBarTitle(Text("New Voyage"))
            .sheet(isPresented: $voyageSheetShow) {
                NavigationView {
                    VStack {
                        Text(timeString(time: TimeInterval(managerClass.secondElapsed)))
                        Form {
                            TextField("Final Gold", text: $finalGold)
                                .keyboardType(.decimalPad)
                            TextField("Final Doubloons", text: $finalDoubloons)
                                .keyboardType(.decimalPad)
                        }
                        HStack {
                            Text("+" + String(goldProfit()))
                            Text(String(goldPerHour()) + "/hour")
                            Text("+" + String(doubloonProfit()))
                            Text(String(doubloonsPerHour()) + "/hour")
                        }
                    }
                    .navigationTitle(Text(voyageName != "" ? voyageName : "My Voyage"))
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        Button {
                            showAlert.toggle()
                            managerClass.stop()
                        } label: {
                            Text("Done")
                                .bold()
                        }
                    }
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Done?"),
                        primaryButton: Alert.Button.destructive(Text("Done")) {
                            voyageSheetShow.toggle()
                            //saveVoyage()
                            voyageName = ""
                            initialGold = ""
                            initialDoubloons = ""
                            finalGold = ""
                            finalDoubloons = ""
                        },
                        secondaryButton: Alert.Button.cancel(Text("Continue")) {
                            managerClass.start()
                        })
                }
            }
        }
    }
}

struct PreviousVoyage: View {
    var body: some View {
        Text("Previous Voyage")
    }
}

class ManagerClass: ObservableObject {
    @Published var secondElapsed = 0.9
    var timer = Timer()
    
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { timer in self.secondElapsed += 0.1
        })
    }
    func stop() {
        timer.invalidate()
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
