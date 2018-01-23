//
//  MyButton.swift
//  WelcomeAR
//
//  Created by tab on 2017/12/18.
//  Copyright © 2017年 tab. All rights reserved.
//

import UIKit

class MyButton: UIButton {

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red:0.94, green:0.94, blue:0.94, alpha:1.00)
        setTitleColor(UIColor.darkGray, for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
