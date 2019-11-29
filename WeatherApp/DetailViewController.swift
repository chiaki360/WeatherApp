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
    
    @IBOutlet weak var tempLabel: UILabel!
    
    @IBOutlet weak var weathericon: UIImageView!
    
    @IBOutlet weak var pressureLabel: UILabel!
    
    @IBOutlet weak var humidityLabel: UILabel!
    
    
    @IBOutlet weak var hScrollView: UIScrollView!
    var city : City?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cityNameLabel.text = city?.name
        let urlString = "https://api.openweathermap.org/data/2.5/weather?id=\(city?.id ?? 0)&appid=cd722cdfdd876581cbab1c54072fe755"
        print(urlString)
        if let url = URL(string: urlString) {
            do {
                if let data = try? Data(contentsOf: url) {
                    // parse(json: data)
                    print(String(decoding: data, as: UTF8.self))
                    
                    let decoder = JSONDecoder()
                    
                    let currentWeather = try decoder.decode(CurrentWeather.self, from: data)
                    print(currentWeather)
                    tempLabel.text = String(format: "%.2f", currentWeather.main.temp-273.15)+" °C"
                    let iconname = currentWeather.weather[0].icon+".png"
                    
                    let url = URL(string: "https://openweathermap.org/img/wn/"+iconname)
                    do {
                        let data = try Data(contentsOf: url!)
                        weathericon.image = UIImage(data: data)
                        
                    } catch let err {
                        print("Error : \(err.localizedDescription)")
                    }
                    
                    pressureLabel.text = String(currentWeather.main.pressure) + " hPa"
                    
                    humidityLabel.text = String(currentWeather.main.humidity) + " %"
                    
                } else {
                    showError()
                }
            } catch let error {
                print(error)
            }
        } else {
            showError()
        }
        
        let urlString1 = "https://api.openweathermap.org/data/2.5/forecast?id=\(city?.id ?? 0)&appid=cd722cdfdd876581cbab1c54072fe755"
        print(urlString1)
        if let url = URL(string: urlString1) {
            do {
                if let data = try? Data(contentsOf: url) {
                    // parse(json: data)
                    print(String(decoding: data, as: UTF8.self))
                    
                    let decoder = JSONDecoder()
                    
                    let hourlyWeather = try decoder.decode(HourlyWeather.self, from: data)
                    print(hourlyWeather)
                    /*
                     tempLabel.text = String(format: "%.2f", hourlyWeather.main.temp-273.15)+" °C"
                     let iconname = hourlyWeather.weather[0].icon+".png"
                     
                     let url = URL(string: "https://openweathermap.org/img/wn/"+iconname)
                     do {
                     let data = try Data(contentsOf: url!)
                     weathericon.image = UIImage(data: data)
                     
                     } catch let err {
                     print("Error : \(err.localizedDescription)")
                     }
                     
                     pressureLabel.text = String(currentWeather.main.pressure) + " hPa"
                     
                     humidityLabel.text = String(currentWeather.main.humidity) + " %"
                     */
                } else {
                    showError()
                }
            } catch let error {
                print(error)
            }
        } else {
            showError()
        }
        
        NSLayoutConstraint.activate([
            hScrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            hScrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            
        ])
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 10
        stackView.distribution = .fill
        hScrollView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            // Attaching the content's edges to the scroll view's edges
            stackView.leadingAnchor.constraint(equalTo: hScrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: hScrollView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: hScrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: hScrollView.bottomAnchor),
            
            // Satisfying size constraints
            
            stackView.heightAnchor.constraint(equalTo: hScrollView.heightAnchor)
        ])
        for i in 0...20 {
            
            // Label (has instrinsic content size)
            /*
            let label = UILabel()
            label.backgroundColor = .orange
            label.text = "\(i)."
            label.textAlignment = .center
 */
            let weatherView3hr = WeatherView3hr()
            stackView.addArrangedSubview(weatherView3hr)
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
