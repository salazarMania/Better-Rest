//
//  ContentView.swift
//  BetterRest
//
//  Created by SANIYA KHATARKAR on 17/06/24.
//

import SwiftUI
import CoreML

struct drawText : ViewModifier {
    let font = Font.system(size: 22, weight: .heavy, design: .default)
    
    func body(content: Content) -> some View {
        content
            .font(font)
    }
}
struct drawHorizontalText: View{
    var text : String
    var textResult : String
    
    var body: some View{
        HStack{
            Text(text)
                .modifier(drawText())
                .foregroundColor(.blue)
            
            Text(textResult)
                .modifier(drawText())
                .foregroundColor(.red)
        }
    }
}
struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    let rangesOfCoffee = 0...20
    var recommendedBedTime : String {
        calculateBedTime()
    }
    
    let dates = Date()
    static var defaultWakeTime : Date{
        var components = DateComponents()
        components.hour=7
        components.minute=0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View{
        NavigationStack{
            Form {
                Section(header: Text("When do you want to wake up, m'lady?")){
                    DatePicker("Please enter the time", selection: $wakeUp,displayedComponents: [.hourAndMinute])
                        .labelsHidden()
                        .datePickerStyle(.wheel)
                }
                
                Section(header: Text("How much sleep do you desire, m'lady?")){
                Stepper(value: $sleepAmount,in: 4...12, step: 0.25){
                    Text("\(sleepAmount,specifier: "%g") hours")
                }
                }
                Section(header: Text("Daily coffee intake, m'lady?")){
                    Picker(selection: $coffeeAmount, label: Text("Daily coffee intake")){
                        ForEach(rangesOfCoffee,id: \.self){
                            amount in
                            Text(amount == 1 ? "1 cup" : "\(amount) cups")
                        }
                        
                    }
                    
                }
                drawHorizontalText(text: "M'lady your ideal bedtime is :", textResult: "\(recommendedBedTime)")
            }
                .navigationTitle("Better Rest")
                

            }
        }
    
             
        
            
    func calculateBedTime() -> String{
        do{
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            let components = Calendar.current.dateComponents([.hour,.minute], from: wakeUp)
            let hour = (components.hour ?? 0 ) * 60 * 60
            let minute = (components.minute ?? 0 ) * 60
            let prediction = try model.prediction(wake: Double(hour+minute), estimatedSleep: sleepAmount, coffee:Double( coffeeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            
            return formatter.string (from : sleepTime)
            
        }catch{
            return  "Error"
        }
    }
        struct ContentView_Previews: PreviewProvider {
            static var previews: some View {
                ContentView()
            }
        }
    }
