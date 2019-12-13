//
//  DetailViewController.swift
//  WeatherApp
//
//  Created by VectorYe on 2019/11/01.
//  Copyright © 2019 Chiaki Yuge. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var cityNameLabel: UILabel!
    
    @IBOutlet weak var tempLabel: UILabel!
    
    @IBOutlet weak var weathericon: UIImageView!
    
    @IBOutlet weak var pressureLabel: UILabel!
    
    @IBOutlet weak var humidityLabel: UILabel!
    
    @IBOutlet var collectionVIew: UICollectionView!
    
    var city : City?
    
    var coord : Coord?
    
    var hourlyWeatherList : [List]?
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let list = hourlyWeatherList {
            return list.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print(indexPath.row)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! WeatherViewCell
        if let list = hourlyWeatherList {
            let currList = list[indexPath.row]
            let currMain = currList.main
            
            let date = Date(timeIntervalSince1970: Double(currList.dt))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy hh:mm a"
            dateFormatter.timeZone = .current
            let localDate = dateFormatter.string(from: date)
            cell.cellDate.text = localDate
            
            cell.cellTemperature.text = String(format: "%.2f", currMain.temp-273.15)+" °C"

            cell.cellPressure.text = String(currMain.pressure) + " hPa"
            
            cell.cellHumidity.text = String(currMain.humidity) + " %"
            
            let iconname = currList.weather[0].icon+".png"
            let url = URL(string: "https://openweathermap.org/img/wn/"+iconname)
            do {
                let data = try Data(contentsOf: url!)
                cell.cellWeatherIcon.image = UIImage(data: data)
                
            } catch let err {
                print("Error : \(err.localizedDescription)")
            }
        }
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionVIew.dataSource = self
        collectionVIew.delegate = self
        
        collectionVIew.register(UINib(nibName: "WeatherViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        
        var urlString: String!
        if let _ = city {
            urlString = "https://api.openweathermap.org/data/2.5/weather?id=\(city?.id ?? 0)&appid=cd722cdfdd876581cbab1c54072fe755"
        }
        if let _ = coord {
            urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(coord?.lat ?? 0)&lon=\(coord?.lon ?? 0)&appid=cd722cdfdd876581cbab1c54072fe755"
        }
        
        if let url = URL(string: urlString) {
            do {
                if let data = try? Data(contentsOf: url) {
                    let decoder = JSONDecoder()
                    
                    let currentWeather = try decoder.decode(CurrentWeather.self, from: data)
                    cityNameLabel.text = currentWeather.name
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
        
        var urlString1: String!
        if let _ = city {
            urlString1 = "https://api.openweathermap.org/data/2.5/forecast?id=\(city?.id ?? 0)&appid=cd722cdfdd876581cbab1c54072fe755"
        }
        if let _ = coord {
            urlString1 = "https://api.openweathermap.org/data/2.5/forecast?lat=\(coord?.lat ?? 0)&lon=\(coord?.lon ?? 0)&appid=cd722cdfdd876581cbab1c54072fe755"
        }
        
        if let url = URL(string: urlString1) {
            do {
                if let data = try? Data(contentsOf: url) {
                    print(String(decoding: data, as: UTF8.self))
                    
                    let decoder = JSONDecoder()
                    
                    let hourlyWeather = try decoder.decode(HourlyWeather.self, from: data)
                    hourlyWeatherList = hourlyWeather.list
                } else {
                    showError()
                }
            } catch let error {
                print(error)
            }
        } else {
            showError()
        }
    }
    
    func showError() {
        let ac = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}
