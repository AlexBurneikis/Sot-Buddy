//
//  ContentView.swift
//  Sot Buddy
//
//  Created by Alexander Burneikis on 10/6/2022.
//

import SwiftUI

struct voyage: Identifiable, Encodable, Decodable {
    let name: String
    let duration: Int
    let gold: Int
    let doubloons: Int
    var id: String { name }
}

var voyages: [voyage] = []

struct ContentView: View {
    func getVoyages() -> Array<voyage> {
        let outputArray: [voyage] = []
        let decoderData: Data = UserDefaults.standard.data(forKey: "voyages")!
        do {
            let decoder = JSONDecoder()
            let outputData = try decoder.decode([voyage].self, from: decoderData)
            print(outputData)
        } catch {
            print("decoding no worky")
        }
        return outputArray
    }
    @State var previousVoyages = voyages
    
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
                        ForEach(previousVoyages) { voyage in
                            NavigationLink(destination: {
                                PreviousVoyage()
                            }, label: {
                                HStack {
                                    Text(voyage.name)
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
            .onAppear {
                previousVoyages = getVoyages()
            }
        }
    }
}

struct NewVoyage: View {
    @State private var voyageName = ""
    @State private var initialGold = ""
    @State private var initialDoubloons = ""
    @State private var voyageSheetShow = false
    @State private var showAlert = false
    @State private var alertNameTaken = false
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
    
    func saveVoyage() {
        let outputVoyage = voyage(name: (voyageName.count != 0 ? voyageName : "My Voyage"), duration: Int(managerClass.secondElapsed), gold: goldProfit(), doubloons: doubloonProfit())
        voyages.insert(outputVoyage, at: 0)
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(voyages)
            UserDefaults.standard.set(encodedData, forKey: "voyages")
        } catch {
            print("Unable to encode outputVoyage")
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
                        managerClass.start()
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
                title: Text("Voyage Name already exists"),
                dismissButton: Alert.Button.destructive(Text("Done")) {
                    voyageName = ""
                })}
        .navigationBarTitle(Text("New Voyage"))
        .sheet(isPresented: $voyageSheetShow, onDismiss: {
            managerClass.stop()
            voyageName = ""
            initialGold = ""
            initialDoubloons = ""
            finalGold = ""
            finalDoubloons = ""
            managerClass.secondElapsed = 0.9
        }) {
            NavigationView {
                VStack {
                    Text(timeString(time: TimeInterval(managerClass.secondElapsed)))
                    Form {
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
                        saveVoyage()
                        voyageSheetShow.toggle()
                    },
                    secondaryButton: Alert.Button.cancel(Text("Continue")) {
                        managerClass.start()
                    })
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
            .preferredColorScheme(.light)
    }
}
