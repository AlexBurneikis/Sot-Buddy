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
    @State var previousVoyages = voyages
    
    func getVoyages() -> Array<voyage> {
        let decoderData: Data = UserDefaults.standard.data(forKey: "voyages")!
        do {
            let decoder = JSONDecoder()
            let outputData = try decoder.decode([voyage].self, from: decoderData)
            voyages = outputData
            return outputData
        } catch {
            print("Error during decoding")
        }
        return voyages
    }
    
    func timeString(time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    func delete(at offsets: IndexSet) {
        previousVoyages.remove(atOffsets: offsets)
        voyages = previousVoyages
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(voyages)
            UserDefaults.standard.set(encodedData, forKey: "voyages")
        } catch {
            print("Error during encoding")
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section {
                        NavigationLink {
                            NewVoyageView()
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
                                PreviousVoyageView(previousVoyage: voyage)
                            }, label: {
                                HStack {
                                    Text(voyage.name)
                                    Spacer()
                                    Text(timeString(time: TimeInterval(voyage.duration)))
                                        .fontWeight(.light)
                                }
                            })
                        }
                        .onDelete(perform: delete)
                    }
                }
            }
            .navigationBarTitle(Text("Voyages"))
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                previousVoyages = getVoyages()
            }
        }
    }
}

class TimerClass: ObservableObject {
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
