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
    
    var activityIndicatorView = UIActivityIndicatorView()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let list = hourlyWeatherList {
            return list.count
        }
        return 0
    }
    
    // This will construct the 3 hourly forecast view for 5 days
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! WeatherViewCell
        if let list = hourlyWeatherList {
            let currList = list[indexPath.row]
            let currMain = currList.main
            
            let date = Date(timeIntervalSince1970: Double(currList.dt))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy hh:mm a"
            dateFormatter.timeZone = .current
            cell.cellDate.text = dateFormatter.string(from: date)
            
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
        
        // Set parameter for the loading indicator icon
        activityIndicatorView.style = .whiteLarge
        activityIndicatorView.color = .blue
        
        view.addSubview(activityIndicatorView)
    }
    
    // This function make sure that data is loaded before the loading icon animation
    // is stopped, by running two threads together. One for animating the icon and the
    // other to load the data.
    override func viewDidAppear(_ animated: Bool) {
        activityIndicatorView.center = view.center
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
        guard let _ = urlString else {
            showError()
            return
        }
        
        var urlString1: String!
        if let _ = self.city {
            urlString1 = "https://api.openweathermap.org/data/2.5/forecast?id=\(self.city?.id ?? 0)&appid=cd722cdfdd876581cbab1c54072fe755"
        }
        if let _ = self.coord {
            urlString1 = "https://api.openweathermap.org/data/2.5/forecast?lat=\(self.coord?.lat ?? 0)&lon=\(self.coord?.lon ?? 0)&appid=cd722cdfdd876581cbab1c54072fe755"
        }

        // Loading icon animation started.
        activityIndicatorView.startAnimating()
        
        var currentWeather : CurrentWeather?
        // Starting a new thread for download data and parsing.
        DispatchQueue.global().async {
            
            if let url = URL(string: urlString) {
                do {
                    if let data = try? Data(contentsOf: url) {
                        let decoder = JSONDecoder()
                        
                        currentWeather = try decoder.decode(CurrentWeather.self, from: data)
                        
                    } else {
                        self.showError()
                    }
                } catch let error {
                    print(error)
                }
            } else {
                self.showError()
            }
                        
            var hourlyWeather : HourlyWeather?
            if let url = URL(string: urlString1) {
                do {
                    if let data = try? Data(contentsOf: url) {
                        print(String(decoding: data, as: UTF8.self))
                        
                        let decoder = JSONDecoder()
                        
                        hourlyWeather = try decoder.decode(HourlyWeather.self, from: data)
                        //self.hourlyWeatherList = hourlyWeather.list
                    } else {
                        self.showError()
                    }
                } catch let error {
                    print(error)
                }
            } else {
                self.showError()
            }
            
            // Merging threads
            DispatchQueue.main.async {
                // Loading icon animation stopped.
                self.activityIndicatorView.stopAnimating()
                
                // Condition to prevent crash when wifi is not avilable.
                if let cw = currentWeather {
                    self.cityNameLabel.text = cw.name
                    self.tempLabel.text = String(format: "%.2f", cw.main.temp-273.15)+" °C"
                    let iconname = cw.weather[0].icon+".png"
                    let url = URL(string: "https://openweathermap.org/img/wn/"+iconname)
                    do {
                        let data = try Data(contentsOf: url!)
                        self.weathericon.image = UIImage(data: data)
                    } catch let err {
                        print("Error : \(err.localizedDescription)")
                    }
                    self.pressureLabel.text = String(cw.main.pressure) + " hPa"
                    self.humidityLabel.text = String(cw.main.humidity) + " %"
                }
                // 3 Hourly data
                self.hourlyWeatherList = hourlyWeather?.list
                // Need to reload 3 hourly data to display.
                self.collectionVIew.reloadData()
            }
        }
    }
    
    func showError() {
        DispatchQueue.main.async {
            let ac = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
        }
    }
}
