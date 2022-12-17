//
//  PlayerViewController.swift
//  Video Editor
//
//  Created by Владимир Воробьев on 14.11.2022.
//

import UIKit
import AVFoundation
import AVKit
import GPUImage

protocol PlayerViewControllerDelegate {
    func startRecording ()
    func finishRecording ()
}


class PlayerViewController: UIViewController {

    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var backwardEndView: PlayerControlButtonView!
    @IBOutlet weak var backwardView: PlayerControlButtonView!
    @IBOutlet weak var playView: PlayerControlButtonView!
    @IBOutlet weak var pauseView: PlayerControlButtonView!
    @IBOutlet weak var stopView: PlayerControlButtonView!
    @IBOutlet weak var forwardView: PlayerControlButtonView!
    @IBOutlet weak var forwardEndView: PlayerControlButtonView!
    
    var delegate: PlayerViewControllerDelegate?
    
    var assetToPlay: AVAsset?
    var player: AVPlayer?
    var playerLayer: CALayer?
    var gpuMovie = GPUImageMovie()
    let filteredView = GPUImageView()
    var compositionForRecordUrl: URL?
    var filteredMovieUrl: URL?
    
    var editor: mediaEditor?

    var newVideoURL: URL? {
        didSet {
            newItemIni()
        }
    }
    
    var newAudioURLs: [URL]? {
        didSet {
            do {
                assetToPlay = try editor?.assetForNewAudio(newAudioURLs)
            } catch  {
                if let editorError = error as? VideoEditorErrors {
                    alertCall(self, "Внимание", editorError.rawValue)
                } else {
                    alertCall(self, "Внимание", "Неизвестная ошибка \(error)")
                }
                return
            }
            playerConfig()
            if let filter = filterSeleted{
                gpuMovie.removeAllTargets()
                let gpuFilters = filter.createFilters()
                filtersConfig(gpuFilters)
            }

        }
    }
    
    var filterSeleted: Filters? {
        didSet {
            assetToPlay = editor?.assetForNewFilter(filterSeleted)
            gpuMovie.removeAllTargets()
            if let filter = filterSeleted{
                let gpuFilters = filter.createFilters()
                filtersConfig(gpuFilters)

            } else {
                gpuMovie.addTarget(filteredView)
            }
            gpuMovie.startProcessing()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //to be developed later
        backwardEndView.isHidden = true
        backwardView.isHidden = true
        forwardView.isHidden = true
        forwardEndView.isHidden = true
        
        //to be unvisible till video is choosen
        shareButton.layer.cornerRadius = 5
        shareButton.isHidden = true
        
        backwardEndView.delegate = self
        backwardView.delegate = self
        playView.delegate = self
        pauseView.delegate = self
        stopView.delegate = self
        forwardView.delegate = self
        forwardEndView.delegate = self

    }
    
    

    @IBAction func shareButton(_ sender: Any) {
        //pop up controller for quality choosing
        let qualityChooseVC = storyboard?.instantiateViewController(identifier: "QualityChoosePopUpVC") as! QualityChoosePopUpViewController
        qualityChooseVC.delegate = self
        self.addChild(qualityChooseVC)
        qualityChooseVC.view.frame = CGRect(x: view.center.x, y: 0, width: view.frame.width / 2, height: view.frame.height)
        view.addSubview(qualityChooseVC.view)
        qualityChooseVC.didMove(toParent: self)
    }
    
 
    func totalReset () {
        
        assetToPlay = nil
        player = nil
        playerLayer = nil
    }
    
    func newItemIni () {
        totalReset()
        guard let url = newVideoURL else {return}
        let asset = AVAsset(url: url)
        //new Video - new editor
        do {
            editor = try mediaEditor(newMovieAsset: asset)
        } catch let error {
            let error = error as! VideoEditorErrors
            alertCall(self, "Внимание", error.rawValue)
        }
        editor?.delegate = self
        // to show selected video without editing
        assetToPlay = asset
        //new player configuration ana put layer over label
        playerConfig()
        shareButton.isHidden = false

    }
    
    func playerConfig () {
        guard let asset = assetToPlay else {return}
        let playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        
        gpuMovie = GPUImageMovie(playerItem: playerItem)
        gpuMovie.playAtActualSpeed = true
        gpuMovie.addTarget(filteredView)
        gpuMovie.startProcessing()

        playerLayer?.removeFromSuperlayer()
        let layer = filteredView.layer
        layer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat.pi / 2))
        layer.frame = view.bounds
        view.layer.insertSublayer(layer, at: 1)
        playerLayer = layer
    }
  
    func filtersConfig ( _ filters: [GPUImageFilter]) {
        gpuMovie.addTarget(filters.first)
        var i = 0
        while i < filters.count - 1 {
            filters[i].addTarget(filters[i+1])
            i += 1
        }
        filters.last?.addTarget(filteredView)
    }
    
    func playButtonPressed () {
        
        player?.play()
    }
    
    func pauseButtonPressed () {
        player?.pause()
    }
    
    func stopButtonPressed () {
        player?.pause()
        playerConfig()
        let filter = filterSeleted
        filterSeleted = filter
        }
     
  
    @objc func share(_ url: URL?){
        guard let url = url else {
            return
        }
            let objectsToShare = [url] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

                //Excluded Activities
                activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
                //

                activityVC.popoverPresentationController?.sourceView = view
                self.present(activityVC, animated: true, completion: nil)
                }
   
}

extension PlayerViewController: PlayerControlButtonViewDelegate {
    

    func viewTouched(sender: Any) {
        
        switch (sender as? NSObject) {
        case backwardEndView: print ("backwardEnd pressed")
        case backwardView: print ("backward pressed")
        case playView: playButtonPressed()//print ("play pressed")
        case pauseView: pauseButtonPressed () //print ("pause pressed")
        case stopView: stopButtonPressed () //print ("stop pressed")
        case forwardView: print ("forward pressed")
        case forwardEndView: print ("forwardEnd pressed")
        default : print ("unknown view pressed")

        }
    }
}

extension PlayerViewController: mediaEditorDelegate {
    func sharePreparedFile(url: URL?, error: VideoEditorErrors?) {
        if let error = error {
            delegate?.finishRecording()
            alertCall(self, "Внимание", error.rawValue)
        } else {
            delegate?.finishRecording()
            share(url)
        }
    }
    
}

extension PlayerViewController: QualityChoosePopUpViewControllerDelegate {
    func startRecord(_ quality: Bool) {
        
                delegate?.startRecording()
                do {
                    try editor?.record(quality)
                } catch  {
                    delegate?.finishRecording()
                    if let editorError = error as? VideoEditorErrors {
                        alertCall(self, "Внимание", editorError.rawValue)
                    } else {
                        alertCall(self, "Внимание", "Неизвестная ошибка \(error)")
                    }
                }
    }
    
    
}
