//
//  ContentView.swift
//  HWS_100_SwiftUI_Project01_WeSplit
//
//  Created by Steve Blythe on 29/11/2020.
//

import SwiftUI

struct ContentView: View {
    @State private var amount = ""
    //@State private var peopleIndex = 2
    @State private var numPeople = ""
    @State private var tipIndex = 2
    @State private var grandTotal = 0.0

    let tipPercentages = [0, 10, 12.5, 15, 17.5, 20]

    var totalPerPerson: Double {
        //let peopleCount = Double(peopleIndex + 2)
        let peopleCount = Double(numPeople) ?? 1
        let tip = Double(tipPercentages[tipIndex])
        let orderAmount = Double(amount) ?? 0

        var tipAmount: Double
        if tip == 0 {
            tipAmount = 0
        } else {
            tipAmount = orderAmount / tip
        }

        grandTotal = orderAmount + tipAmount
        let amountPerPerson = grandTotal / peopleCount

        return amountPerPerson
    }

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section {
                        TextField("Amount", text: $amount)
                            .keyboardType(.decimalPad)

                        TextField("Number of People", text: $numPeople)
                            .keyboardType(.numberPad)
                    }

                    Section(header: Text("How much tip do you want to leave?")) {
                        Picker("Tip percentage", selection: $tipIndex) {
                            ForEach(0 ..< tipPercentages.count) {
                                Text("\(self.tipPercentages[$0], specifier: "%.1f")%")
                            }
                        }.pickerStyle(SegmentedPickerStyle())
                    }

                    Section(header: Text("Total Amount Plus Tip")) {
                        Text("£\(grandTotal, specifier: "%.2f")")
                            .foregroundColor(tipIndex == 0 ? Color.red : Color.black)
                    }
                }
                Spacer()
                Section(header: Text("Amount per Person")) {
                    Text("£\(totalPerPerson, specifier: "%.2f")")
                }
                Spacer()

            }.navigationBarTitle("WeSplit")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
