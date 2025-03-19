//
//  RecordButton.swift
//  Camera Record
//
//  Created by mluis on 15/3/25.
//

import SwiftUI

struct RecordButton: View {
    var isRecording: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .stroke(Color.white, lineWidth: 5)
                    .frame(width: 70, height: 70)
                    .animation(.easeInOut(duration: 0.5), value: isRecording)
                
                RoundedRectangle(cornerRadius: isRecording ? 8 : 30)
                    .fill(Color.red)
                    .frame(width: isRecording ? 30 : 60, height: isRecording ? 30 : 60)
                    .animation(.spring(response: 0.5, dampingFraction: 0.5), value: isRecording)
                
            }
        }
    }
}

#Preview {
    struct Preview: View {
        @State private var isRecording: Bool = false
        var body: some View {
            RecordButton(isRecording: isRecording, action: {
                isRecording = !isRecording
            })
            .background(Color.gray)
        }
    }
    
    return Preview()
}
