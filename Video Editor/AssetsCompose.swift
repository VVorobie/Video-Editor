//
//  AssetsCompose.swift
//  Lesson_13
//
//  Created by Владимир Воробьев on 19.04.2022.
//

import Foundation
import AVFoundation



class AssetCompose {
    
  
    static var shared = AssetCompose()
    

// Main Class Method
    func compositionCreate (_ videoAssets: [AVAsset], _ audioAssets: [AVAsset]?) throws -> AVAsset {
        let composition = AVMutableComposition()
        
        var nextTrackStartPoint = CMTime.zero
        
            for i in 0...videoAssets.count - 1 {
                guard let compositionVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID:Int32(kCMPersistentTrackID_Invalid) ) else {
                    throw VideoEditorErrors.videoTrackCreationError}
                
                do {
                    try compositionVideoTrack.insertTimeRange(CMTimeRange(start: .zero, duration: videoAssets[i].duration), of: videoAssets[i].tracks[0], at: nextTrackStartPoint)
                } catch {
                    throw VideoEditorErrors.compositionVideoTrackArrayError}
                
                nextTrackStartPoint = nextTrackStartPoint + videoAssets[i].duration
  
            }

        if let audioAssets = audioAssets {
//Sound track forming
            let fullVideoDuration = nextTrackStartPoint

            guard let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID:Int32(kCMPersistentTrackID_Invalid) ) else {
                throw VideoEditorErrors.audioTrackCreationError}
            var time = CMTime.zero
            var i = 0
            while time < fullVideoDuration {
                var duration = audioAssets[i].duration
                if time + duration > fullVideoDuration {duration = fullVideoDuration - time}
                
                do {
                    try audioTrack.insertTimeRange(CMTimeRange(start: .zero, duration: duration), of: audioAssets[i].tracks(withMediaType: .audio)[0], at: time)
                } catch {
                    throw VideoEditorErrors.compositionAudioTrackArrayError
                }

                time = time + duration
                i += 1
                if i == audioAssets.count {i = 0}  // if videoDuratio is too long - again first audio
            }
        }
        return (composition)
    }
    
    

}
