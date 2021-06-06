//
//  ContentView.swift
//  HWS_100_SwiftUI_Project04_BetterRest
//
//  Created by Steve Blythe on 17/01/2021.
//

import SwiftUI
import CoreML

struct ContentView: View {
    
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 0
    @State private var bedtime = ""
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Form {
                    Section(header: Text("When do you want to wake up?")
                                .font(.headline))
                    {
                        DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }.onChange(of: wakeUp, perform: { value in
                        calculateBedtime()
                    })

                    Section(header: Text("Desired amount of sleep")
                                .font(.headline))
                    {
                        Stepper(value: $sleepAmount, in: 4...12, step: 0.25) {
                            Text("\(sleepAmount, specifier: "%g") hours")
                            }
                        .onChange(of: sleepAmount, perform: { value in
                            calculateBedtime()
                        })
                        .accessibility(value: Text("You want to sleep for \(sleepAmount) hours"))
                    }
                    
                    Section(header: Text("Daily coffee intake")
                                .font(.headline))
                    {
//                        Picker(selection: $coffeeAmount, label: Text("Coffee Amount")) {
//                            ForEach(0..<21) {
//                                Text("\($0)")
//                            }
//                        }
                        Stepper(value: $coffeeAmount, in: 1...20) {
                            Text("\(coffeeAmount) \(coffeeAmount == 1 ? "Cup" : "Cups")")
                        }
                        .onChange(of: coffeeAmount, perform: { value in
                            calculateBedtime()
                        })
                        .accessibility(value: Text("You drink \(coffeeAmount) cups of coffee per day"))
                    }
                    
                    Section(header: Text("Recommended Bedtime").font(.headline))
                    {
                        Text("\(bedtime)").foregroundColor(.blue)
                    }
                }
                .navigationBarTitle("BetterRest", displayMode: .large)
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            }
        }
        .onAppear(perform: {
            calculateBedtime()
        })
    }
    
    func calculateBedtime() {
        let model: SleepCalculator = {
            do {
                let config = MLModelConfiguration()
                return try SleepCalculator(configuration: config)
            } catch {
                print(error)
                fatalError("Couldn't create SleepCalculator")
            }
        }()
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
        let hour = (components.hour ?? 0) * 60 * 60
        let minute = (components.minute ?? 0) * 60
        
        do {
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))

            let sleepTime = wakeUp - prediction.actualSleep
            
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            
            bedtime = formatter.string(from: sleepTime)

            //alertMessage = formatter.string(from: sleepTime)
            //alertTitle = "Your ideal bedtime is…"
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
            showingAlert = true
        }
    }
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
