//
//  TextField.swift
//  Camera Record
//
//  Created by mluis on 15/3/25.
//

import SwiftUI

struct PossitiveNumberInputRow: View {
    var title: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            
            TextField(title, text: $text)
                .keyboardType(.numberPad)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
                .onChange(of: text) { newValue in
                    let filtered = newValue.filter { $0.isNumber }
                    if filtered != newValue {
                        text = filtered
                    }
                    if let value = Int(filtered), value <= 0 {
                        text = ""
                    }
                }
        }
    }
}

#Preview {
    struct Preview: View {
        @State var text: String = ""
        var body: some View {
            List {
                PossitiveNumberInputRow(title: "Title", text: $text)
            }
        }
    }
    
    return Preview()
}
