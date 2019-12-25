//
//  ViewController.swift
//  WeatherApp
//
//  Created by Chiaki Yuge on 2019/10/11.
//  Copyright © 2019 Chiaki Yuge. All rights reserved.
//

//here


import UIKit

class ViewController: UITableViewController{
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
        
        // Loading country and city list from JSon file.
        readCountry()
        readCities()
        
        let items = countryDict.keys
        for item in items.sorted() {
            countries.append(item)
        }
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Countries"
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // When doing a search base on country.
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
        let country: String
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "City") as? CityTableViewController {
            if isFiltering {
                country = filteredCountries[indexPath.row]
            } else {
                country = countries[indexPath.row]
            }
            // Creating city list
            let cityList = countryDict[country]
            // Sorted by city name in alphabatical order
            vc.cities = cityList!.sorted(by: {$0.name < $1.name})
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func readCities() {
        if let path = Bundle.main.path(forResource: "current.city.list", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let decoder = JSONDecoder()
                
                let cities = try decoder.decode([City].self, from: data)
                
                for city in cities {
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
    }
    
    func readCountry() {
        if let path = Bundle.main.path(forResource: "ISO3166-1.alpha2", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let decoder = JSONDecoder()
                
                countriesCodeDict = try decoder.decode([String:String].self, from: data)
            } catch let error {
                print(error)
            }
        }
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
