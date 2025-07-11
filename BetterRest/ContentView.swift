//
//  ContentView.swift
//  BetterRest
//
//  Created by Наташа Спиридонова on 09.07.2025.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        NavigationStack {
            Form {
                VStack(alignment: .leading, spacing: 0) {
                    Text("When do you want to make up?")
                        .font(.headline)
                    
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Desired amount of sleep")
                        .font(.headline)
                    
                    Stepper("\(sleepAmount.formatted())", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                VStack(alignment: .leading, spacing: 0) {
                   Text("Daily coffee intake")
                        .font(.headline)
                    
                    Picker("\(coffeeAmount)", selection: $coffeeAmount) {
                        ForEach(0..<21) {
                            Text("^[\($0) cup](inflect: true)")
                        }
                    }
                    
//                    Stepper("^[\(coffeeAmount) cup](inflect: true)", value: $coffeeAmount, in: 1...20)
                }
                
                VStack(alignment: .trailing, spacing: 0) {
                    Text(calculateBedtime.title)
                        .font(.headline)
                    Text(calculateBedtime.message)
                        .font(.largeTitle)
                }
            }
            .navigationTitle("BetterRest")
        }
    }
    
    var calculateBedtime: (title: String, message: String) {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            
            return ("Your ideal baedtime is...",sleepTime.formatted(date: .omitted, time: .shortened))
            
        } catch {
            return ("Error", "Sorry, there was a problem calculating your bedtime.")
        }
    }
}

#Preview {
    ContentView()
}
