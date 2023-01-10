//
//  VideoCollectionViewController.swift
//  Video Editor
//
//  Created by Владимир Воробьев on 17.11.2022.
//

import UIKit
import Photos
import PhotosUI

protocol VideoCollectionViewControllerDelegate {
    
    func newUrlHandler(_ newURLString: String, _ fileName: String, _ fileIcon: UIImage)    
}

private let reuseIdentifier = "VideoCell"

class VideoCollectionViewController: UICollectionViewController {
    
    @IBOutlet weak var collectionVIewFLowLayout: UICollectionViewFlowLayout!
    
    var delegate: VideoCollectionViewControllerDelegate?
    
    private var fetchResult: PHFetchResult<PHAsset>!
    private var phAssets: [PHAsset] = []
    private var phAssetNames: [String] = []
    private var assetCollection: PHAssetCollection!
    private var availableWidth: CGFloat = 0
    private let imageManager = PHCachingImageManager()
    private var thumbnailSize: CGSize!
    private var dataLoadError: VideoEditorErrors?
    
    private var dataLoaded = false {
        didSet {if dataLoaded == true {collectionView.reloadData()}}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try fetchAllVideos ()
        } catch let error {
            dataLoadError = error as? VideoEditorErrors
        }
    }
       
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard dataLoadError == nil else {
            alertCall(self, "Внимание", dataLoadError?.rawValue) //in file ALerts
            return
        }
        
        // from layoutSubView
        let width = view.bounds.inset(by: view.safeAreaInsets).width
        // Adjust the item size if the available width has changed.
        if availableWidth != width {
            availableWidth = width
            let columnCount = (availableWidth / 120).rounded(.towardZero)
            let itemLength = (availableWidth - columnCount - 1) / columnCount
            collectionVIewFLowLayout.itemSize = CGSize(width: itemLength, height: itemLength + 29)
        }
        
        // Determine the size of the thumbnails to request from the PHCachingImageManager.
            let scale = UIScreen.main.scale
            let cellSize = collectionVIewFLowLayout.itemSize
            thumbnailSize = CGSize(width: cellSize.width * scale - 4, height: cellSize.height * scale  - 29)
        
    }
    
 

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return phAssetNames.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! VideoCollectionViewCell
        cell.thumbnailLabel.text = phAssetNames[indexPath.row]
 
        // Request an image for the asset from the PHCachingImageManager.
        let asset = phAssets[indexPath.row]
        cell.representedAssetIdentifier = asset.localIdentifier
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            // Set the cell's thumbnail image only if it's still showing the same asset.
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.thumbnailView.image = image
            }
        })
        return cell
    }

    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let phAsset = phAssets[indexPath.row]
        phAsset.requestContentEditingInput(with: PHContentEditingInputRequestOptions(), completionHandler: { [weak self] contentEditingInput, _ in
            guard let strURL = (contentEditingInput?.audiovisualAsset as? AVURLAsset)?.url.absoluteString else {
                alertCall(self!, "Внимание", VideoEditorErrors.urlUnreadable.rawValue)//see in file Alerts
                return
                
            }
                if let cell = collectionView.cellForItem(at: indexPath) as? VideoCollectionViewCell,
                    let fileName = cell.thumbnailLabel.text,
                    let fileIcon = cell.thumbnailView.image {
                    self?.delegate?.newUrlHandler(strURL, fileName, fileIcon)
                    self?.presentingViewController?.dismiss(animated: true, completion: nil)
                }
          })

    }

    func fetchAllVideos () throws {
        //request allMedia
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchResult = PHAsset.fetchAssets(with: options)
        
        
        guard let fetchResult = fetchResult else {throw VideoEditorErrors.fetchError}
        //forming array of video phAssets
        // select only vide and unknown (which may be also video but closed for processing)
            for i in (0..<fetchResult.count) {
                let phAsset = fetchResult.object(at: i)
                if phAsset.mediaType == .video || phAsset.mediaType == .unknown{
                    self.phAssets.append(phAsset)
                }
            }
        guard phAssets.count > 0 else {throw VideoEditorErrors.noVideoError}
         // get array of videofile names
        for asset in phAssets {
            asset.requestContentEditingInput(with: PHContentEditingInputRequestOptions(), completionHandler: { [weak self] contentEditingInput, _ in
                    if let strURL = (contentEditingInput?.audiovisualAsset as? AVURLAsset)?.url.absoluteString {
                        self?.phAssetNames.append((self!.getFileNameFromStringURL(strURL)))
                        }
                       else {
                        self?.phAssetNames.append("unknown")
                       }
                    if self?.phAssetNames.count == self?.phAssets.count {self?.collectionView.reloadData()}
                })
        }
    }
 
    func getFileNameFromStringURL (_ stringURL: String) -> String {
        var path = stringURL
        var name = ""
        var letter = path.last
        while letter != "/"  {
            name.insert(path.removeLast(), at: name.startIndex)
            if path.count == 0 {break}
            letter = path.last
        }
        return name
    }
}
