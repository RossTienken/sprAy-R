//
//  customBtn.swift
//  SpAy-R
//
//  Created by Ross Tienken on 1/29/18.
//  Copyright © 2018 TheBoys. All rights reserved.
//

import UIKit

class customButton: UIButton {
    
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

class customDraw: UIButton {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    override func awakeFromNib() {
        backgroundColor = UIColor.white
        layer.cornerRadius = 0.5 * bounds.size.width
        
        layer.borderWidth = 2.0
        layer.borderColor = UIColor.white.cgColor
    }
    
}

class customWheelButton: UIButton {
    var color: UIColor!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, color: UIColor) {
        super.init(frame: frame)
        
        setViewColor(color)
    }
    
    func setViewColor(_ _color: UIColor) {
        color = _color
        setBackgroundColor()
    }
    
    func setBackgroundColor() {
        layer.borderWidth = 2.0
        layer.borderColor = color.cgColor
        layer.cornerRadius = 0.5 * bounds.size.width
        
        backgroundColor = color
    }
}

