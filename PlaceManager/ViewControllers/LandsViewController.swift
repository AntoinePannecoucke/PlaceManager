//
//  LandsViewController.swift
//  PlaceManager
//
//  Created by lpiem on 09/02/2022.
//

import UIKit

class LandsViewController : UITableViewController {
    
    @IBOutlet weak var filterPullDownButton: UIButton!
    var category : Category? = nil
    private var currentFilter = Filter.Name
    private var lands : [Landmark] = []
    private let CellIdentifier = "landmarkCell"
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let category = category {
            self.title = category.name
        }
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        
        lands = CoreDataManager.Instance.fetchLandmarks(filter: currentFilter)
        
        let nameFilterAction = UIAction(title: "Name") { [weak self] it in
            guard let self = self else {
                return
            }
            self.menuActionClicked(filter: .Name)
        }
            
        let createdFilterAction = UIAction(title: "Created") { [weak self] it in
            guard let self = self else {
                return
            }
            self.menuActionClicked(filter: .Creation)
        }
            
        let modifiedFilterAction = UIAction(title: "Modified") { [weak self] it in
            guard let self = self else {
                return
            }
            self.menuActionClicked(filter: .Modification)
        }
            
        let menu = UIMenu(children: [nameFilterAction, createdFilterAction, modifiedFilterAction])
        filterPullDownButton.menu = menu
        filterPullDownButton.showsMenuAsPrimaryAction = true
    }
    
    private func menuActionClicked(filter: Filter){
        currentFilter = filter
        lands = CoreDataManager.Instance.fetchLandmarks(filter: currentFilter)
        tableView.reloadData()
    }
    
    //MARK: - User Interactions
    
    

    
    //MARK: - Table View
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lands.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath)
        let landmark = lands[indexPath.row]
        
        cell.textLabel?.text = landmark.title
        cell.detailTextLabel?.text = landmark.desc
                
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let landmark = lands[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Supprimer") { [weak self]_, _, completion in
            guard let self = self else {
                return
            }
            
            CoreDataManager.Instance.deleteLandmark(landmark: landmark)
            self.lands.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
        }
        
        let swipeActionConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
        
        return swipeActionConfiguration
    }
    
}

//MARK: - Extensions

extension LandsViewController : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchQuery = searchController.searchBar.text
        lands = CoreDataManager.Instance.fetchLandmarks(searchQuery: searchQuery, filter: currentFilter)
        tableView.reloadData()
    }
    
}
