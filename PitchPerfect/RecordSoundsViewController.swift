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

    @IBOutlet weak var currentUserlabel: UILabel!
    @IBOutlet weak var recordLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    
    enum RecordingState { case recording, notRecording }
    enum User { case userOne, userTwo }
    
    var currentRecordingState = RecordingState.notRecording
    var currentUser = User.userOne
    
    var audioRecorder: AVAudioRecorder!
    
    override func viewWillAppear(_ animated: Bool) {
        prepareRecording()
        configureUI()
    }
    
    @IBAction func startOrStopRecording(_ sender: AnyObject) {
        if (currentRecordingState == .notRecording && currentUser == .userOne) {
            currentRecordingState = .recording
            configureUI()
            startRecording()
        } else if (currentRecordingState == .recording && currentUser == .userOne) {
            currentRecordingState = .notRecording
            currentUser = .userTwo
            configureUI()
            pauseRecording()
        } else if (currentRecordingState == .notRecording && currentUser == .userTwo) {
            currentRecordingState = .recording
            configureUI()
            continueRecording()
        } else {
            currentRecordingState = .notRecording
            currentUser = .userOne
            configureUI()
            stopRecording()
        }
    }
    
    private func prepareRecording() {
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let recordingFileName = "recordedAudio.wav"
        let pathArray = [dirPath, recordingFileName]
        let filePath = URL(string: pathArray.joined(separator: "/"))!
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with:AVAudioSessionCategoryOptions.defaultToSpeaker)
        
        try! audioRecorder = AVAudioRecorder(url: filePath, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
    }

    private func startRecording() {
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    private func pauseRecording() {
        audioRecorder.pause()
    }
    
    private func continueRecording() {
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    private func stopRecording() {
        audioRecorder.stop()
        let session = AVAudioSession.sharedInstance()
        try! session.setActive(false)
    }
    
    private func configureUI() {
        displayCurrentUser()
        displayRecordingMessage()
    }
    
    private func displayCurrentUser() {
        if (currentUser == .userOne) {
            currentUserlabel.text = "Person 1"
        } else {
            currentUserlabel.text = "Person 2"
        }
    }
    
    private func displayRecordingMessage() {
        if (currentRecordingState == .recording) {
            recordLabel.text = "Tap to finish recording"
            recordButton.setImage(UIImage(named: "Stop.png"), for: UIControlState.normal)
        } else {
            recordLabel.text = "Tap to start recording"
            recordButton.setImage(UIImage(named: "Record.png"), for: UIControlState.normal)
        }
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
