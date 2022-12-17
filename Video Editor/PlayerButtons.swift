//
//  PlayerButtons.swift
//  Video Editor
//
//  Created by Владимир Воробьев on 17.12.2022.
//

import Foundation
import UIKit


protocol PlayerControlButtonViewDelegate {
    func viewTouched(sender: Any)
}

class PlayerControlButtonView: UIImageView {
    
    var delegate: PlayerControlButtonViewDelegate?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesBegan(touches, with: event)
        
        delegate?.viewTouched(sender: self)
    }
}
