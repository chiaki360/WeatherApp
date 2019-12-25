//
//  CityViewControllerTableViewController.swift
//  WeatherApp
//
//  Created by Shaiful Nizam on 2019/10/16.
//  Copyright © 2019 Chiaki Yuge. All rights reserved.
//

import UIKit

// This view displays the city list

class CityTableViewController: UITableViewController {
    var cities = [City]()
    
    var filteredCities: [City] = []
    
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Cities"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredCities.count
        }
        return cities.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cities", for: indexPath)
        let city: City
        if isFiltering {
            city = filteredCities[indexPath.row]
        } else {
            city = cities[indexPath.row]
        }
        cell.textLabel?.text = city.name
        return cell
    }
    
    // This will load the detail view controller
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailViewController = DetailViewController(nibName: "DetailViewController", bundle: nil)
        let city: City
        if isFiltering {
            city = filteredCities[indexPath.row]
        } else {
            city = cities[indexPath.row]
        }
        detailViewController.city = city
        self.navigationController!.pushViewController(detailViewController, animated: true)
    }
    
    func filterContentForSearchText(_ searchText: String) {
        filteredCities = cities.filter { (city: City) -> Bool in
            return city.name.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
}

extension CityTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
}
