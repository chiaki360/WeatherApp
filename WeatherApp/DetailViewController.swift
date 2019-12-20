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
        
        //activityIndicatorView.center = view.center
        activityIndicatorView.style = .whiteLarge
        activityIndicatorView.color = .blue
        
        view.addSubview(activityIndicatorView)
    }
    
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
            
            var urlString1: String!
            if let _ = self.city {
                urlString1 = "https://api.openweathermap.org/data/2.5/forecast?id=\(self.city?.id ?? 0)&appid=cd722cdfdd876581cbab1c54072fe755"
            }
            if let _ = self.coord {
                urlString1 = "https://api.openweathermap.org/data/2.5/forecast?lat=\(self.coord?.lat ?? 0)&lon=\(self.coord?.lon ?? 0)&appid=cd722cdfdd876581cbab1c54072fe755"
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

            DispatchQueue.main.async {
                self.activityIndicatorView.stopAnimating()
                self.cityNameLabel.text = currentWeather?.name
                self.tempLabel.text = String(format: "%.2f", (currentWeather?.main.temp)!-273.15)+" °C"
                let iconname = (currentWeather?.weather[0].icon)!+".png"
                let url = URL(string: "https://openweathermap.org/img/wn/"+iconname)
                do {
                    let data = try Data(contentsOf: url!)
                    self.weathericon.image = UIImage(data: data)
                    
                } catch let err {
                    print("Error : \(err.localizedDescription)")
                }
                self.pressureLabel.text = String(currentWeather!.main.pressure) + " hPa"
                self.humidityLabel.text = String(currentWeather!.main.humidity) + " %"

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
