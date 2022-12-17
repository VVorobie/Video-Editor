//
//  VideoCollectionViewCell.swift
//  Video Editor
//
//  Created by Владимир Воробьев on 17.11.2022.
//

import UIKit

class VideoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbnailView: UIImageView!
    
    @IBOutlet weak var thumbnailLabel: UILabel!
    
    var representedAssetIdentifier: String!
    
    
}
