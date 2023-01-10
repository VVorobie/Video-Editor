//
//  MediaEditor.swift
//  Video Editor
//
//  Created by Владимир Воробьев on 28.11.2022.
//

import Foundation
import AVFoundation
import GPUImage

protocol mediaEditorDelegate {
    func sharePreparedFile (url: URL?, error: VideoEditorErrors?)
}

class mediaEditor {
    
    var delegate: mediaEditorDelegate?
    
    let composer = AssetCompose.shared
    
    var assetForShow: AVAsset

    private let assetOriginal: AVAsset
    private var audioAssets: [AVAsset]?
    private var filter: Filters?
    
    private var compositionForRecordUrl: URL!
    private var filteredMovieUrl: URL!
    
    private var recordProcess = 0 {
        didSet {
            recordOrgfnizer(recordProcess)
        }
    }
    
    init(newMovieAsset: AVAsset) throws {
        self.assetForShow = newMovieAsset
        self.assetOriginal = newMovieAsset
        (self.compositionForRecordUrl, self.filteredMovieUrl) = try urlsForRecordingPrepare()
    }
    
    deinit {
        var path = compositionForRecordUrl.path
        if FileManager.default.fileExists(atPath: path){
            try? FileManager.default.removeItem(at: compositionForRecordUrl)
        }
        path = filteredMovieUrl.path
        if FileManager.default.fileExists(atPath: path){
            try? FileManager.default.removeItem(at: filteredMovieUrl)
        }
    }
    

    
    func urlsForRecordingPrepare () throws  -> (compositionUrl: URL, filteredMovieUrl: URL){
       
        if let documentsDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            var url = documentsDirectoryUrl.appendingPathComponent("tempMovie.m4v")
            try deleteFileInUrl(url)
            let compositionUrl = url
            
            url = documentsDirectoryUrl.appendingPathComponent("tempFilteredMovie.mov")
            try deleteFileInUrl(url)
            let filteredMovieUrl = url
            
            return (compositionUrl, filteredMovieUrl)
        } else {
            throw VideoEditorErrors.urlCreationError
        }
    }
    
    func deleteFileInUrl (_ url: URL) throws {
        let path = url.path
        if FileManager.default.fileExists(atPath: path){
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                throw VideoEditorErrors.fileDeletionError
            }
        }
    }
    
    func assetForNewAudio (_ audioAssetUrls: [URL]?) throws -> AVAsset {
        if let urls = audioAssetUrls {
            var assets: [AVAsset] = []
                for url in urls {
                    let asset = AVAsset(url: url)
                    assets.append(asset)
                }
            audioAssets = assets
            assetForShow = try composer.compositionCreate([assetOriginal], audioAssets)

        } else {
            audioAssets = nil
            assetForShow = assetOriginal
        }
        return assetForShow
    }
    
    func assetForNewFilter (_ newFilter: Filters?) -> AVAsset {
        filter = newFilter
        return assetForShow
    }
    

    
    func recordOrgfnizer(_ variants: Int) {
//0 - no process, 1 - filtered video is recording in temp file, 2 - add choosen sound tp filtered video
        // 21 - add original sound to filtered video, 3 - no filter choosen, just record video + chooden sound, 31 - nothing choosen, just original vide + orig sound
        
        switch variants {
        case 0: return
        case 1: return
        case 2: recordCompleteion(filteredMovieUrl, nil, audioAssets)
        case 21: recordCompleteion(filteredMovieUrl, nil, [assetOriginal])
        case 3: recordCompleteion(nil, assetOriginal, audioAssets)
        case 31: recordCompleteion(nil, assetOriginal, [assetOriginal])
        default: return
        }
    }
    
    func record (_ quality: Bool) throws {
        guard recordProcess == 0 else {return}  //don't interrupt ongoing record
        recordProcess = 1
        if let _ = filter {
            let asset = try composer.compositionCreate([assetOriginal], nil)
            try export(asset, compositionForRecordUrl) { [weak self] (completed) in
                        if completed {
                            self?.wrightMovie(self!.compositionForRecordUrl, self!.filteredMovieUrl, quality, {
                                if let _ = self?.audioAssets {
                                    self?.recordProcess = 2  // with audio files choosen
                                } else {
                                    self?.recordProcess = 21  //audio files did not choosen, add original sound
                                }
                            })
                        }
                    }
        } else {
            if let _ = audioAssets {
                recordProcess = 3  // with audio files choosen
            } else {
                recordProcess = 31  //audio files did not choosen, add original sound
            }
        }
    }
    
    func recordCompleteion (_ videoFileUrl: URL?, _ videoAsset: AVAsset?, _ audioAssets: [AVAsset]?) {
        var assetForVideo: AVAsset!
        if let url = videoFileUrl {
            assetForVideo = AVAsset(url: url)
        } else if let asset = videoAsset {
            assetForVideo = asset
        } else {
            return
        }
        
        var assetForRecord: AVAsset!
        var error: VideoEditorErrors?
        do {
            assetForRecord = try self.composer.compositionCreate([assetForVideo], audioAssets)
        } catch let error1 {
            error = error1 as? VideoEditorErrors
            self.delegate?.sharePreparedFile(url: nil, error: error)
            self.recordProcess = 0
        }
        do {
            try self.export(assetForRecord, self.compositionForRecordUrl) {completed in
                if completed {
                    self.delegate?.sharePreparedFile(url: self.compositionForRecordUrl, error: nil)
                    self.recordProcess = 0
                    }
                }
        } catch let error1 {
            error = error1 as? VideoEditorErrors
            self.delegate?.sharePreparedFile(url: nil, error: error)
            self.recordProcess = 0
        }

    }
    
    
    func export(_ asset: AVAsset,_ recordUrl: URL, _ completion: @escaping (_ success: Bool) -> Void) throws {

        try deleteFileInUrl(recordUrl)
        
        guard let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPreset640x480) else {throw VideoEditorErrors.exportSessionError}
        
        exporter.outputURL = recordUrl
        exporter.outputFileType = .m4v
        exporter.exportAsynchronously {
            DispatchQueue.main.async {
                completion(exporter.status == .completed)
            }
        }
      
    }
    
    
    func wrightMovie (_ filetUrl: URL, _ newFileUrl: URL, _ quality: Bool, _ completion: @escaping () -> Void) {

        try! deleteFileInUrl(newFileUrl)// if something wrong with url - app protected in intitializer, so stay with "!"
        
        let movieFile = GPUImageMovie(url: filetUrl)
        
        //make filters

        let filtersGpu = filter?.createFilters() ??  [GPUImageBrightnessFilter()]
        movieFile?.addTarget(filtersGpu.first)
        //if filter is combination of GPUFiltres - construct pipeline
        var  i = 0
        while i < filtersGpu.count - 1 {
            filtersGpu[i].addTarget(filtersGpu[i+1])
            i += 1
        }
        
        //make movie Writter
        let asset = AVURLAsset(url: filetUrl)
        let assetTrack = asset.tracks(withMediaType: .video)[0]
        let size = assetTrack.naturalSize

        let movieWriter = GPUImageMovieWriter(movieURL: newFileUrl, size: size)
        movieWriter?.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)

        // apply last filter in pipeLine to writter
        filtersGpu.last?.addTarget(movieWriter)

        movieWriter?.shouldPassthroughAudio = true
        movieWriter?.hasAudioTrack = false
        movieFile?.audioEncodingTarget = nil

        movieFile?.playAtActualSpeed = quality //quality of record!

        movieWriter?.startRecording()
        movieFile?.startProcessing()

        movieWriter?.completionBlock = {
            filtersGpu.last?.removeTarget(movieWriter)
            movieWriter?.finishRecording()
                    completion()
        }
            
            
    }


}
