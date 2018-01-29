//
//  customBtn.swift
//  SpAy-R
//
//  Created by Ross Tienken on 1/29/18.
//  Copyright © 2018 TheBoys. All rights reserved.
//

import UIKit

class customBtn: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func awakeFromNib() {
        backgroundColor = UIColor.lightGray
        layer.cornerRadius = 10.0
        
        layer.borderWidth = 2.0
        layer.borderColor = UIColor.white.cgColor
    }

}
