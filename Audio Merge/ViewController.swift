//
//  ViewController.swift
//  Audio Merge
//
//  Created by Vibhanshu Vaibhav on 14/02/18.
//  Copyright © 2018 Vibhanshu Vaibhav. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    
    let audio1 = "audio1.wav"
    let audio2 = "audio2.wav"
    let final = "final.m4a"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func recordFirstAudio(_ sender: Any) {
        recordAudio(duration: 60, fileName: audio1)
    }
    
    @IBAction func playFirstAudio(_ sender: Any) {
        playAudio(fileName: audio1)
    }
    
    @IBAction func recordSecondAudio(_ sender: Any) {
        recordAudio(duration: 60, fileName: audio2)
    }
    
    @IBAction func playSecondAudio(_ sender: Any) {
        playAudio(fileName: audio2)
    }
    
    @IBAction func mixFinalAudio(_ sender: Any) {
        mixAudio()
    }
    
    @IBAction func playFinalAudio(_ sender: Any) {
        playAudio(fileName: final)
    }
    
    // fetch the path location
    
    func getFilePath(fileName: String) -> URL {
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0]
        let pathArray = "\(dirPath + "/" + fileName)"
        let filePath = URL(fileURLWithPath: pathArray)
        return filePath
    }
    
    // record audio
    
    func recordAudio(duration: Int, fileName: String) {
        let filePath = getFilePath(fileName: fileName)
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with:AVAudioSessionCategoryOptions.defaultToSpeaker)
        
        try! audioRecorder = AVAudioRecorder(url: filePath, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.prepareToRecord()
        audioRecorder.record(forDuration: TimeInterval(duration))
    }
    
    // play audio
    
    func playAudio(fileName: String) {
        let filePath = getFilePath(fileName: fileName)
        
        try! audioPlayer = AVAudioPlayer(contentsOf: filePath)
        audioPlayer.delegate = self
        audioPlayer.prepareToPlay()
        audioPlayer.play()
    }
    
    // mixing the two audio files and exporting the final output
    
    func mixAudio() {
        let mixer = AVMutableComposition()
        let audioTrack1 = mixer.addMutableTrack(withMediaType: .audio, preferredTrackID: CMPersistentTrackID())
        let audioTrack2 = mixer.addMutableTrack(withMediaType: .audio, preferredTrackID: CMPersistentTrackID())
        
        let audio1 = AVURLAsset(url: getFilePath(fileName: self.audio1))
        let track1 = audio1.tracks(withMediaType: .audio)
        let audioAssetTrack1 = track1[0]
        let audioRange1 = CMTimeRangeMake(kCMTimeZero, audio1.duration)
        
        let audio2 = AVURLAsset(url: getFilePath(fileName: self.audio2))
        let track2 = audio2.tracks(withMediaType: .audio)
        let audioAssetTrack2 = track2[0]
        let audioRange2 = CMTimeRangeMake(kCMTimeZero, audio2.duration)
        
        do {
            try audioTrack1?.insertTimeRange(audioRange1, of: audioAssetTrack1, at: kCMTimeZero)
            try audioTrack2?.insertTimeRange(audioRange2, of: audioAssetTrack2, at: audio1.duration)
        } catch {
            print(error)
        }
        
        let exportSession = AVAssetExportSession(asset: mixer, presetName: AVAssetExportPresetAppleM4A)
        exportSession?.outputFileType = AVFileType.m4a
        exportSession?.outputURL = getFilePath(fileName: final)
        if (exportSession?.outputURL?.isFileURL)! {
            do {
                try FileManager.default.removeItem(at: getFilePath(fileName: final))
            } catch {
                print(error)
            }
        }
        exportSession?.exportAsynchronously(completionHandler: {
            if exportSession?.status == .completed {
                print("Mixing complete")
            }
            if exportSession?.status == .failed {
                print(exportSession?.error! as Any)
            }
        })
    }
    
}

