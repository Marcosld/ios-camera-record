//
//  ContentView.swift
//  Camera Record
//
//  Created by mluis on 15/3/25.
//

import SwiftUI

struct LandingScreen: View {
    @State private var countdownTime: String = ""
    @State private var workTime: String = ""
    @State private var path = [CameraTimerConfiguration]()
    @State private var inputError = false

    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                List {
                    PossitiveNumberInputRow(title: "Countdown time", text: $countdownTime)
                    PossitiveNumberInputRow(title: "Work time", text: $workTime)
                }
                
                HStack {
                    Spacer()
                    Button {
                        if let countdown = Int(countdownTime), let work = Int(workTime), countdown > 0, work > 0 {
                            path.append(CameraTimerConfiguration(countdownTime: countdown, workTime: work))
                        } else {
                            inputError = true
                        }
                    } label: {
                        Text("Record!")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    Spacer()
                }
                .padding(16)
                
            }
            .navigationDestination(for: CameraTimerConfiguration.self) { selection in
                CameraView(countdownTime: selection.countdownTime, workTime: selection.workTime)
            }
            .alert(isPresented: $inputError) {
                Alert(title: Text("Error"), message: Text("Please enter valid values greater than 0"), dismissButton: .default(Text("OK")))
            }
        }
    }
}

class CameraTimerConfiguration: NSObject {
    var countdownTime: Int
    var workTime: Int
    
    init(countdownTime: Int, workTime: Int) {
        self.countdownTime = countdownTime
        self.workTime = workTime
    }
}

#Preview {
    LandingScreen()
}
