//
//  ViewController.swift
//  WeatherApp
//
//  Created by Chiaki Yuge on 2019/10/11.
//  Copyright © 2019 Chiaki Yuge. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    var cityDictionary = ["Japan": ["Tokyo","Osaka","Kyoto", "Sapporo", "Kusatsu"],
                          "China": ["Beijing","Shanghai","Shenzhen","Dalian","Nanjing"],
                          "South Korea": ["Seoul","Busan","Jeju"],
                          "Indonesia": ["Jakarta","Semarang","Bali"],
                          "Malaysia": ["Kuala Lumpur","Putra Jaya","Ipoh","Shah Alam","Kucing"]]
    
    var countries = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        readCities()
        //let items = ["Japan","China","South Korea", "Indonesia", "Malaysia"]
        let items = cityDictionary.keys
        for item in items.sorted() {
            countries.append(item)
        }
        print(countries)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Country", for: indexPath)
        cell.textLabel?.text = countries[indexPath.row]
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 1: try loading the "Detail" view controller and typecasting it to be DetailViewController
        print("Creating CityTableView")
        if let vc = storyboard?.instantiateViewController(withIdentifier: "City") as? CityTableViewController {
            print("CityTableView created.")
            //vc.detailItem = petitions[indexPath.row]
            let cityList = cityDictionary[countries[indexPath.row]]!
            vc.cities = cityList.sorted()
            // 2: success! Set its selectedImage property
            //vc.selectedImage = countries[indexPath.row]
            
            // 3: now push it onto the navigation controller
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    func readCities() {
        if let path = Bundle.main.path(forResource: "city.list.json", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let decoder = JSONDecoder()
                
                if let jsonCities = try? decoder.decode(Cities.self, from: data) {
                    let cities = jsonCities.cities
                    print(cities)
                    tableView.reloadData()
                }
            } catch {
                // handle error
            }
        }
    }
}

