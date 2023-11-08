//
//  AddRecordViewController.swift
//  sesKayit
//
//  Created by Ebrar Etiz on 30.10.2023.
//

import UIKit
import AVFoundation

class AddRecordViewController: UIViewController, AVAudioRecorderDelegate {
  
    
    @IBOutlet weak var recordButton: UIButton!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recordingSession = AVAudioSession.sharedInstance()
       
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.recordTapped()
                    } else {
                        // failed to record!
                        self.showError("Recording permission was denied. Please enable it in settings.")

                    }
                }
            }
        } catch {
            // failed to record!
            showError("Failed to set up recording session.")

        }

    
    }
    
  
        
    @IBAction func recordTapped(_ sender: Any) {
        if audioRecorder == nil {
                   startRecording()
               } else {
                   finishRecording(success: true)
               }
    }
    func startRecording() {
        let alertController = UIAlertController(title: "New Recording", message: "Enter a name for your recording:", preferredStyle: .alert)
        alertController.addTextField()

        let recordAction = UIAlertAction(title: "Start Recording", style: .default) { [unowned self] action in
            if let name = alertController.textFields?.first?.text {
                let audioFilename = self.getDocumentsDirectory().appendingPathComponent("\(name).m4a")
                self.beginRecording(to: audioFilename)
            }
        }

        alertController.addAction(recordAction)
        present(alertController, animated: true)
    }

    func beginRecording(to fileURL: URL) {
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            recordButton.setTitle("Tap to Stop", for: .normal)
        } catch {
            finishRecording(success: false)
        }
    }

       
       func finishRecording(success: Bool) {
           audioRecorder.stop()
           audioRecorder = nil

           if success {
               recordButton.setTitle("Tap to Re-record", for: .normal)
           } else {
               recordButton.setTitle("Tap to Record", for: .normal)
               showError("Recording failed. Please try again.")
           }
       }
     
       @objc func recordTapped() {
           if audioRecorder == nil {
               startRecording()
           } else {
               finishRecording(success: true)
           }
       }
       
       func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
           if !flag {
               finishRecording(success: false)
           }
       }
       
       func getDocumentsDirectory() -> URL {
           let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
           return paths[0]
       }
       
       func showError(_ message: String) {
           let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .default))
           present(alert, animated: true)
       }
   }
