//
//  filterView.swift
//  Video Editor
//
//  Created by Владимир Воробьев on 30.11.2022.
//

import UIKit

protocol FilterViewDelegate {
    
    func filterDidSelected (_ sender: FilterView)
    func filterDeselected (_ sender: FilterView)
}

class FilterView: UIView {

    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var selectedView: UIImageView!
    
    var filter: Filters?
    
    var delegate: FilterViewDelegate?
    
    var filterSelectedFlag = false
    
    static func loadFromNib() -> FilterView {
        let nib = UINib(nibName: "FilterView", bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! FilterView
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if filterSelectedFlag {
            selectedView.isHidden = true
            filterSelectedFlag = false
            delegate?.filterDeselected(self)
        } else {
            selectedView.isHidden = false
            filterSelectedFlag = true
            delegate?.filterDidSelected(self)
        }
    }
    
    
}
