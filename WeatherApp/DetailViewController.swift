//
//  DetailViewController.swift
//  WeatherApp
//
//  Created by VectorYe on 2019/11/01.
//  Copyright © 2019 Chiaki Yuge. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var cityNameLabel: UILabel!
    var city : City?
    override func viewDidLoad() {
        super.viewDidLoad()

        cityNameLabel.text = city?.name
        let urlString = "https://api.openweathermap.org/data/2.5/weather?id=\(city?.id ?? 0)&appid=cd722cdfdd876581cbab1c54072fe755"
        print(urlString)
        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
               // parse(json: data)
                print(String(decoding: data, as: UTF8.self))
                
            } else {
                showError()
            }
        } else {
            showError()
        }
    
        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func showError() {
        let ac = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}
