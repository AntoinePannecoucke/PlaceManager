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
    
    override func viewWillAppear(_ animated: Bool){
        if let category = category {
            lands = CoreDataManager.Instance.fetchLandmarks(filter: currentFilter, category: category)
        }
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let category = category {
            self.title = category.name
        }
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        
        createMenu()
        filterPullDownButton.showsMenuAsPrimaryAction = true
    }
    
    private func createMenu() {
        let nameFilterAction = UIAction(title: "Name", state: (currentFilter == .Name ? .on : .off)) { [weak self] it in
            guard let self = self else {
                return
            }
            
            self.menuActionClicked(filter: .Name)
        }
        
        let createdFilterAction = UIAction(title: "Created", state: (currentFilter == .Creation ? .on : .off)) { [weak self] it in
            guard let self = self else {
                return
            }
            
            self.menuActionClicked(filter: .Creation)
        }
        
        let modifiedFilterAction = UIAction(title: "Modified", state: (currentFilter == .Modification ? .on : .off)) { [weak self] it in
            guard let self = self else {
                return
            }
            
            self.menuActionClicked(filter: .Modification)
        }

        let menu = UIMenu(children: [nameFilterAction, createdFilterAction, modifiedFilterAction])
        filterPullDownButton.menu = menu
    }
    
    private func menuActionClicked(filter: Filter){
        currentFilter = filter
        if let category = category {
            lands = CoreDataManager.Instance.fetchLandmarks(filter: currentFilter, category: category)
        }
        createMenu()
        tableView.reloadData()
    }
    
    //MARK: - User Interactions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch  (segue.identifier) {
        case "createLandmarkSegue":
            if let navigationController = segue.destination as? UINavigationController {
                if let destination = navigationController.children[0] as? CreateLandViewController {
                    destination.category = self.category
                    destination.landsDelegate = self
                }
            }
            break
        case "showLandmarkDetailsSegue":
            if let navigationController = segue.destination as? UINavigationController {
                if let destination = navigationController.children[0] as? LandmarkDetailsViewModel {
                    let cell = sender as! UITableViewCell
                    if let indexPath = tableView.indexPath(for: cell) {
                        destination.landmark = lands[indexPath.row]
                    }
                }
            }
            break
        default:
            return
        }
    }

    
    //MARK: - Table View
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lands.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath)
        let landmark = lands[indexPath.row]
        
        cell.textLabel?.text = landmark.title
        cell.detailTextLabel?.text = landmark.desc
        if let data = landmark.image {
            cell.imageView?.image = UIImage(data: data)
        }
                
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
        if let category = category {
            lands = CoreDataManager.Instance.fetchLandmarks(searchQuery: searchQuery, filter: currentFilter, category: category)
        }
        tableView.reloadData()
    }
    
}

extension LandsViewController : LandsDelegate {
    
    func updateLand(_ controller: CreateLandViewController, landmark: Landmark) {
        //DO NOTHING
    }
    
    
    func addLand(_ controller: CreateLandViewController) {
        if let category = category {
            lands = CoreDataManager.Instance.fetchLandmarks(filter: currentFilter, category: category)
            tableView.reloadData()
        }
        controller.dismiss(animated: true)
    }
        
}
