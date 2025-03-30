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
    @FocusState private var focusedField: Field?
    
    enum Field {
        case field1, field2
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                List {
                    PossitiveNumberInputRow(title: "Countdown time", text: $countdownTime)
                        .focused($focusedField, equals: .field1)
                    PossitiveNumberInputRow(title: "Work time", text: $workTime)
                        .focused($focusedField, equals: .field2)
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
            .toolbar {
                if focusedField == .field1 {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Next") {
                            focusedField = .field2
                        }
                    }
                }
                if focusedField == .field2 {
                    ToolbarItemGroup(placement: .keyboard) {
                        Button("Previous") {
                            focusedField = .field1
                        }
                        Spacer()
                    }
                }
            }
            .onAppear {
                focusedField = .field1
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
