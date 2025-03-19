//
//  CameraView.swift
//  Camera Record
//
//  Created by mluis on 15/3/25.
//

import SwiftUI
import AVFoundation
import Photos

struct CameraPreview: UIViewRepresentable {
    @Binding var session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let layer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
          layer.session = session
          layer.frame = uiView.bounds
        }
    }
}

struct CameraView: View {
    var countdownTime: Int
    var workTime: Int
    @StateObject private var recorder = Recorder()
    @State private var countdown = 0
    @State private var timer: Timer?
    
    var body: some View {
        ZStack {
            CameraPreview(session: $recorder.session)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        recorder.toggleCamera()
                    }) {
                        Image(systemName: "camera.rotate")
                            .font(.title2)
                            .padding()
                    }
                }
                if countdown > 0 {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("\(countdown)")
                            .font(.system(size: 128, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                }
                Spacer()
                RecordButton(isRecording: recorder.isRecording, action: {
                    self.toggleRecording()
                })
                .padding(.bottom, 20)
            }
        }
    }
    
    private func toggleRecording() {
        if (recorder.isRecording) {
            self.cancelRecording()
        } else {
            self.startRecording()
        }
    }
    
    private func startRecording() {
        recorder.startRecording()

        startCountdown(seconds: countdownTime, onFinished: {
            startCountdown(seconds: workTime, onFinished: {
                timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { timer in
                    recorder.saveRecording()
                })
            })
        })
    }
    
    private func cancelRecording() {
        recorder.cancelRecording()
        self.stopCountdown()
    }
    
    private func stopCountdown() {
        timer?.invalidate()
    }
    
    private func startCountdown(seconds: Int, onFinished: @escaping () -> Void) {
        countdown = seconds
        if (countdown < 4) {
            self.playBeepOk()
        }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.countdown -= 1
            if self.countdown == 0 {
                playBeepKo()
                timer.invalidate()
                onFinished()
            } else if (countdown < 4) {
                playBeepOk()
            }
        }
    }
    
    private func playBeepOk() {
            AudioServicesPlaySystemSound(1052)
        }
    
    private func playBeepKo() {
            AudioServicesPlaySystemSound(1054)
        }
}

class Recorder: NSObject, AVCaptureFileOutputRecordingDelegate, ObservableObject {
    @Published var session = AVCaptureSession()
    @Published var isRecording = false
    private let movieOutput = AVCaptureMovieFileOutput()
    private var recordingDelegate: RecordingDelegate?
    
    override init() {
        super.init()
        addAudioInput()
        addVideoInput()
        if session.canAddOutput(movieOutput) {
          session.addOutput(movieOutput)
        }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
          self?.session.startRunning()
        }
    }
    
    private func addAudioInput() {
        guard let device = AVCaptureDevice.default(for: .audio) else { return }
        guard let input = try? AVCaptureDeviceInput(device: device) else { return }
        if session.canAddInput(input) {
          session.addInput(input)
        }
    }
    
    private func addVideoInput() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else { return }
        guard let input = try? AVCaptureDeviceInput(device: device) else { return }
        if session.canAddInput(input) {
            session.addInput(input)
        }
    }
    
    func toggleCamera() {
        guard let currentInput = session.inputs.first as? AVCaptureDeviceInput else { return }
        
        session.beginConfiguration()
        
        session.removeInput(currentInput)
        
        let newDevice: AVCaptureDevice
        if currentInput.device.position == .front {
            newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)!
        } else {
            newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)!
        }
        
        guard let newInput = try? AVCaptureDeviceInput(device: newDevice) else { return }
        
        if session.canAddInput(newInput) {
            session.addInput(newInput)
        }
        
        session.commitConfiguration()
    }
    
    func startRecording() {
        guard let url =
                FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("video.mp4") else { return }
        if movieOutput.isRecording == false {
            if FileManager.default.fileExists(atPath: url.path) {
                try? FileManager.default.removeItem(at: url)
            }
            recordingDelegate = RecordingDelegate()
            movieOutput.startRecording(to: url, recordingDelegate: recordingDelegate!)
            isRecording = true
        }
    }
    
    func cancelRecording() {
        if movieOutput.isRecording {
            movieOutput.stopRecording()
            isRecording = false
        }
    }

    func saveRecording() {
        if movieOutput.isRecording {
            recordingDelegate?.shouldSaveVideoToPhotosLibrary = true
            movieOutput.stopRecording()
            isRecording = false
        }
    }

    func fileOutput(_ output: AVCaptureFileOutput,
                  didStartRecordingTo fileURL: URL,
                  from connections: [AVCaptureConnection]) {
        print("Recording started!")
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error recording: \(error.localizedDescription)")
            return
        }

        // Save video to Photos
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
        }) { saved, error in
            if saved {
                print("Successfully saved video to Photos.")
            } else if let error = error {
                print("Error saving video to Photos: \(error.localizedDescription)")
            }
        }
    }
}

class RecordingDelegate : NSObject, AVCaptureFileOutputRecordingDelegate {
    var shouldSaveVideoToPhotosLibrary: Bool = false
    
    func fileOutput(_ output: AVCaptureFileOutput,
                  didStartRecordingTo fileURL: URL,
                  from connections: [AVCaptureConnection]) {
        print("Recording started!")
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error recording: \(error.localizedDescription)")
            return
        }
        
        if !shouldSaveVideoToPhotosLibrary {
            print("Discarded latest video recording.")
            return
        }

        // Save video to Photos
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
        }) { saved, error in
            if saved {
                print("Successfully saved video to Photos.")
            } else if let error = error {
                print("Error saving video to Photos: \(error.localizedDescription)")
            }
        }
    }
    
}
