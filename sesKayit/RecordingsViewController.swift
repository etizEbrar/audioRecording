//
//  RecordingsViewController.swift
//  sesKayit
//
//  Created by Ebrar Etiz on 30.10.2023.
//

import UIKit
import AVFoundation
import CoreData

class RecordingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    
    var recordings: [URL] = []
    var audioPlayer: AVAudioPlayer?

 

        override func viewDidLoad() {
            super.viewDidLoad()
 
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
                   loadRecordedFiles()
        }

    func loadRecordedFiles() {
           let fileManager = FileManager.default
           if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
               do {
                   let fileURLs = try fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)
                   recordings = fileURLs.filter { $0.pathExtension == "m4a" }
               } catch {
                   showError("Failed to load recordings: \(error)")
               }
           }
           tableView.reloadData()
       }
    // ...
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadRecordedFiles() // Her görünümde kayıtları yeniden yükle
    }
    // ...


        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return recordings.count
       }


        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = recordings[indexPath.row].deletingPathExtension().lastPathComponent
           return cell
       }

        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           do {
               audioPlayer = try AVAudioPlayer(contentsOf: recordings[indexPath.row])
               audioPlayer?.delegate = self
               audioPlayer?.play()
           } catch {
               showError("Failed to play recording: \(error)")
           }
       }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Dosyayı sil
            let fileManager = FileManager.default
            do {
                try fileManager.removeItem(at: recordings[indexPath.row])
                // Kayıtlar listesinden de silin
                recordings.remove(at: indexPath.row)
                // Hücreyi tableView'dan sil
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                showError("Could not delete recording: \(error)")
            }
        }
    }


       func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
           if flag {
               audioPlayer = nil
           }
       }
       
       func showError(_ message: String) {
           let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .default))
           present(alert, animated: true)
       }
   

}
