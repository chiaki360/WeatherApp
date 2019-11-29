//
//  WeatherView3hr.swift
//  WeatherApp
//
//  Created by Shaiful Nizam on 2019/11/29.
//  Copyright © 2019 Chiaki Yuge. All rights reserved.
//

import UIKit

class WeatherView3hr: UIView {
    let kCONTENT_XIB_NAME = "WeatherView3hr"
    
    @IBOutlet var contentView: UIView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        //contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

}
