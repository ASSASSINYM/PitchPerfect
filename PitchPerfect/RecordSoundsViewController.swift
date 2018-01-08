//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Husayn Hakeem on 1/6/18.
//  Copyright © 2018 HusaynHakeem. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var recordLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    
    enum RecordingState { case recording, notRecording }
    var currentRecordingState = RecordingState.notRecording
    
    var audioRecorder: AVAudioRecorder!
    
    @IBAction func startOrStopRecording(_ sender: AnyObject) {
        if (currentRecordingState == .notRecording) {
            currentRecordingState = .recording
            configureUI()
            startRecording()
        } else {
            currentRecordingState = .notRecording
            configureUI()
            stopRecording()
        }
    }

    private func startRecording() {
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let recordingFileName = "recordedAudio.wav"
        let pathArray = [dirPath, recordingFileName]
        let filePath = URL(string: pathArray.joined(separator: "/"))!
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with:AVAudioSessionCategoryOptions.defaultToSpeaker)
        
        try! audioRecorder = AVAudioRecorder(url: filePath, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    private func stopRecording() {
        audioRecorder.stop()
        let session = AVAudioSession.sharedInstance()
        try! session.setActive(false)
    }
    
    private func configureUI() {
        var label = "Tap to start recording"
        var imageName = "Record.png"
        
        if (currentRecordingState == .recording) {
            label = "Tap to finish recording"
            imageName = "Stop.png"
        }
        
        recordLabel.text = label
        recordButton.setImage(UIImage(named: imageName), for: UIControlState.normal)
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        } else {
            print("Error zhile saving audio recording")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording" {
            let playSoundsViewController = segue.destination as! PlaySoundsViewController
            playSoundsViewController.recordedAudioURL = sender as! URL
        }
    }
}
