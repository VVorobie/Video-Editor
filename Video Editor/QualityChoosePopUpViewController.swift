//
//  QualityChoosePopUpViewController.swift
//  Video Editor
//
//  Created by Владимир Воробьев on 16.12.2022.
//

import UIKit

protocol QualityChoosePopUpViewControllerDelegate {
    func startRecord(_ quality: Bool)
}

class QualityChoosePopUpViewController: UIViewController {

    var delegate: QualityChoosePopUpViewControllerDelegate?
    
    @IBOutlet weak var middleQualityButton: UIButton!
    
    @IBOutlet weak var originalQualityButton: UIButton!
    
    @IBOutlet weak var exitButton: UIButton!
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.1, alpha: 0.7)
        middleQualityButton.layer.cornerRadius = 10
        originalQualityButton.layer.cornerRadius = 10
        exitButton.layer.cornerRadius = 10
        
        popUpAnimate ()
    }
    
    @IBAction func middleQuality(_ sender: Any) {
        
        delegate?.startRecord(false)
        closeAnimate ()
    }
    
    
    @IBAction func originalQuality(_ sender: Any) {
        
        delegate?.startRecord(true)
        closeAnimate ()
    }
    
    
    @IBAction func exitButton(_ sender: Any) {
        closeAnimate ()
    }
    
    func popUpAnimate () {
        view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        view.alpha = 0
        UIView.animate(withDuration: 0.5) {
            self.view.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.view.alpha = 1
        }
    }
    
    func closeAnimate () {
        UIView.animate(withDuration: 0.5) {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0
        } completion: { (finish) in
            self.view.removeFromSuperview()
        }

        
    }

}
