//
//  ViewController.swift
//  WeatherApp
//
//  Created by Chiaki Yuge on 2019/10/11.
//  Copyright © 2019 Chiaki Yuge. All rights reserved.
//

//here


import UIKit

class ViewController: UITableViewController {
    //var cityDictionary = ["Japan": ["Tokyo","Osaka","Kyoto", "Sapporo", "Kusatsu"],
    //                      "China": ["Beijing","Shanghai","Shenzhen","Dalian","Nanjing"],
    //                      "South Korea": ["Seoul","Busan","Jeju"],
    //                      "Indonesia": ["Jakarta","Semarang","Bali"],
    //                      "Malaysia": ["Kuala Lumpur","Putra Jaya","Ipoh","Shah Alam","Kucing"]]
    
    var countryDict = [String:[City]]()
    var countries = [String]()
    var countriesCodeDict = [String:String]()

    var filteredCountries: [String] = []

    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
      return searchController.isActive && !isSearchBarEmpty
    }
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        print("Try to read cities from Json file.")
        readCountry()
        readCities()
        //let items = ["Japan","China","South Korea", "Indonesia", "Malaysia"]
        //let items = cityDictionary.keys
        let items = countryDict.keys
        for item in items.sorted() {
            countries.append(item)
        }
        //print(countries)
        
        // 1
        searchController.searchResultsUpdater = self
        // 2
        searchController.obscuresBackgroundDuringPresentation = false
        // 3
        searchController.searchBar.placeholder = "Search Countries"
        // 4
        navigationItem.searchController = searchController
        // 5
        definesPresentationContext = true
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
          return filteredCountries.count
        }
        return countries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Country", for: indexPath)
        let country: String
        if isFiltering {
            country = filteredCountries[indexPath.row]
        } else {
            country = countries[indexPath.row]
        }
        cell.textLabel?.text = country
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 1: try loading the "Detail" view controller and typecasting it to be DetailViewController
        print("Creating CityTableView")
        if let vc = storyboard?.instantiateViewController(withIdentifier: "City") as? CityTableViewController {
            print("CityTableView created.")
            //vc.detailItem = petitions[indexPath.row]
            //let cityList = cityDictionary[countries[indexPath.row]]!
            let country: String
            if isFiltering {
                country = filteredCountries[indexPath.row]
            } else {
                country = countries[indexPath.row]
            }
            let cityList = countryDict[country]
            vc.cities = cityList!.sorted(by: {$0.name < $1.name})
            // 2: success! Set its selectedImage property
            //vc.selectedImage = countries[indexPath.row]
            
            // 3: now push it onto the navigation controller
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    func readCities() {
        print("readCities: Begin")
        if let path = Bundle.main.path(forResource: "current.city.list", ofType: "json") {
            print("Loading json file.")
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                print("Creating data.")
                let decoder = JSONDecoder()
                
                let jsonCities = try decoder.decode([City].self, from: data)
                print("Decoing data.")
                let cities = jsonCities
                print("Numbr of cities = ", cities.count)
                
                for city in cities {
                    //print("Country:",city.country)
                    var countryName = countriesCodeDict[city.country]
                    if countryName == nil {
                        countryName = city.country
                    }
                    var cityArr:[City]? = countryDict[countryName!]
                    if cityArr == nil {
                        countryDict.updateValue([city], forKey: countryName!)
                    } else {
                        cityArr?.append(city)
                        countryDict.updateValue(cityArr!, forKey: countryName!)
                    }
                }
                
                tableView.reloadData()
            } catch let error {
                print(error)
            }
        }
        print("readCities: End")
    }
    
    func readCountry() {
        print("readCountries: Begin")
        if let path = Bundle.main.path(forResource: "ISO3166-1.alpha2", ofType: "json") {
            print("Loading json file.")
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                print("Creating data.")
                let decoder = JSONDecoder()
                
                let jsonCountries = try decoder.decode([String:String].self, from: data)
                print("Decoing data.")
                countriesCodeDict = jsonCountries
                print("Number of countries = ", countriesCodeDict.count)
                //print(countriesCodeDict)
                
            } catch let error {
                print(error)
            }
        }
        print("readCountries: End")
    }

    func filterContentForSearchText(_ searchText: String) {
      filteredCountries = countries.filter { (country: String) -> Bool in
        return country.lowercased().contains(searchText.lowercased())
      }
      
      tableView.reloadData()
    }
}

extension ViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    let searchBar = searchController.searchBar
    filterContentForSearchText(searchBar.text!)
  }
}
