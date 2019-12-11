//
//  WeatherViewCell.swift
//  WeatherApp
//
//  Created by Shaiful Nizam on 2019/11/29.
//  Copyright © 2019 Chiaki Yuge. All rights reserved.
//

import UIKit

class WeatherViewCell: UICollectionViewCell {

    @IBOutlet weak var cellWeatherIcon: UIImageView!
    
    @IBOutlet weak var cellDate: UILabel!
    
    @IBOutlet weak var cellTemperature: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
