//
//  ViewController.swift
//  Video Editor
//
//  Created by Владимир Воробьев on 14.11.2022.
//

import UIKit
import Photos

class ViewController: UIViewController {

    var playerVC: PlayerViewController?
    var videoCollectionVC: VideoCollectionViewController?
    var musicTabelVC: MusicTableViewController?
    
    @IBOutlet weak var videoDidChosenLabel: UILabel!
    @IBOutlet weak var audioDidChosenLabel: UILabel!
    
    @IBOutlet weak var videoChoosingButton: UIButton!
    @IBOutlet weak var audioChoosingButton: UIButton!
    @IBOutlet weak var filtersStack: UIStackView!
    
    var shadowView = UIView()
    var spinner = UIActivityIndicatorView()
    
    var filterViews: [FilterView] = []
    let filtersForUse: [Filters] = [.brightness, .combi3, .pixellation, .comby2]

    var soundList: [(title: String, url: URL)] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        videoChoosingButton.layer.cornerRadius = 7
        audioChoosingButton.layer.cornerRadius = 7
        
        filtersStack.isHidden = true
        audioChoosingButton.isEnabled = false
        videoChoosingButton.isEnabled = false

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let readWriteStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch readWriteStatus {
        case .authorized:
            videoChoosingButton.isEnabled = true
        case .limited:
            videoChoosingButton.isEnabled = true
            alertCall(self, "Внимание", VideoEditorErrors.authorizationLimited.rawValue)
        default:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                if status == .authorized || status == .limited {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.videoChoosingButton.isEnabled = true
                    }
                }
                else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        alertCall(self, "Внимание", VideoEditorErrors.authorizationError.rawValue)
                    }
                }
            }
        }
    }

    @IBAction func videoChoosingButton(_ sender: UIButton) {}
    @IBAction func audioChoosingButton(_ sender: UIButton) {}
    

    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Player View Controller Segue
        if let vc = segue.destination as? PlayerViewController,
           segue.identifier == "EmbedPlayerViewController" {
            playerVC = vc
            playerVC?.delegate = self
            
        }
        
        //VideoCollectionViewSegue
        if let vc = segue.destination as? VideoCollectionViewController,
           segue.identifier == "VideoCollectionViewSegue" {
            videoCollectionVC = vc
            videoCollectionVC?.delegate = self
        }
        
        //MusicTableViewSegue
        if let vc = (segue.destination as? UINavigationController)?.topViewController as? MusicTableViewController,
           segue.identifier == "MusicTabelViewSegue" {

            musicTabelVC = vc
            musicTabelVC?.delegate = self
            musicTabelVC?.soundListUpdateFromVC = soundList
        }
    
    }
 //prepare filter views. Names, icons etc
    func filterViewsPrepare ( _ filters: [Filters], iconImage: UIImage) {
        for filter in filters{
            let filterView = FilterView.loadFromNib()
            filterView.filter = filter
            filterView.label.text = filter.rawValue
            filterView.imageView.image = filter.getFilteredImage(original: iconImage)
            filterView.filterSelectedFlag = false
            filterView.selectedView.isHidden = true
            filterView.delegate = self
            filterViews.append(filterView)
            filtersStack.addArrangedSubview(filterView)
            filtersStack.isHidden = false
        }
    }
    
}

extension ViewController: PlayerViewControllerDelegate {

    func startRecording() {
        shadowView = UIView(frame: view.bounds)
        shadowView.backgroundColor = .gray
        shadowView.alpha = 0.4
        view.addSubview(shadowView)

            DispatchQueue.main.async {[weak self] in
//                self?.spinner = UIActivityIndicatorView(style: .whiteLarge)
                self?.spinner = UIActivityIndicatorView(style: .large)
                self?.spinner.frame = CGRect(x: 0.0, y: 0.0, width: 80.0, height: 80.0)
                self?.spinner.center = CGPoint(x: self!.shadowView.bounds.size.width / 2, y: self!.shadowView.bounds.size.height / 2)
                self?.view.addSubview(self!.spinner)
                self?.spinner.startAnimating()
            }
    }
    
    func finishRecording() {
        shadowView.removeFromSuperview()
        spinner.stopAnimating()
        spinner.removeFromSuperview()

        
        
    }
}

extension ViewController: VideoCollectionViewControllerDelegate {
    func newUrlHandler(_ newURLString: String, _ fileName: String, _ fileIcon: UIImage) {
        
        playerVC?.newVideoURL = URL(fileURLWithPath: newURLString)
        videoDidChosenLabel.text = "Видео: " + fileName
        audioDidChosenLabel.text = ""
        audioChoosingButton.isEnabled = true
        
        if !filtersStack.isHidden {
            let viewsInStack = filtersStack.subviews
            for view in viewsInStack {
                view.removeFromSuperview()
            }
        }
        filterViewsPrepare(filtersForUse, iconImage: fileIcon)
    }
}


extension ViewController: MusicTableViewControllerDelegate {

    func musicDidChosen() {
        var urls: [URL] = []
        var names: [String] = []
        for track in soundList {
            urls.append(track.url)
            names.append(track.title)
        }
        
        if names.count > 1 {
            audioDidChosenLabel.text = "Звук: выбрано " + String(names.count) + " файла "
        } else if names.count == 1 {
            audioDidChosenLabel.text = "Звук: " + names[0]
        } else {
            audioDidChosenLabel.text = "Звук: не выбран"
        }
        
        if urls.count == 0 {
            playerVC?.newAudioURLs = nil
        } else {
            playerVC?.newAudioURLs = urls
        }
    }
    
    func soundListUpdate(_ urls: [URL], _ title: [String]) {
        
        soundList = []
        if urls.count > 0 {
            for i in 0..<urls.count {
                soundList.append((title: title[i], url: urls[i]))
            }
        }

    }
           
}

extension ViewController: FilterViewDelegate {
    
    func filterDidSelected(_ sender: FilterView) {
        for filter in filterViews{
            if filter.label.text != sender.label.text {
                filter.filterSelectedFlag = false  //remove delected flags from other filters
                filter.selectedView.isHidden = true  //remove selectesm sigh from other filters
            }
        }
        playerVC?.filterSeleted = sender.filter
        
    }
    
    func filterDeselected(_ sender: FilterView) {
        playerVC?.filterSeleted = nil
    }
   
}


