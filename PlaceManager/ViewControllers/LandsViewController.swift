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
        
        guard let category = category else {
            ErrorHandler.Instance.handle(sender: self, error: .noCategoryFound)
            return
        }
        
        lands = CoreDataManager.Instance.fetchLandmarks(filter: currentFilter, category: category)
        
        self.title = category.name
        
        
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
        
        guard let category = category else {
            ErrorHandler.Instance.handle(sender: self, error: .noCategoryFound)
            return
        }
        
        lands = CoreDataManager.Instance.fetchLandmarks(filter: currentFilter, category: category)
        
        createMenu()
        tableView.reloadData()
    }
    
    //MARK: - User Interactions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch  (segue.identifier) {
        case "createLandmarkSegue":
            
            guard let navigationController = segue.destination as? UINavigationController,
                  let destination = navigationController.children[0] as? CreateLandViewController
            else {
                ErrorHandler.Instance.handle(sender: self, error: .navigationError)
                return
            }
            
            destination.category = self.category
            destination.landsDelegate = self
            
            if sender != nil {
                destination.landToModify = sender as? Landmark
            }
            
        case "showLandmarkDetailsSegue":
            
            guard let navigationController = segue.destination as? UINavigationController,
                  let destination = navigationController.children[0] as? LandmarkDetailsViewModel
            else {
                ErrorHandler.Instance.handle(sender: self, error: .navigationError)
                return
            }
            
            let cell = sender as! UITableViewCell
            
            guard let indexPath = tableView.indexPath(for: cell) else {
                ErrorHandler.Instance.handle(sender: self, error: .indexPathNotExists)
                return
            }
            
            destination.landmark = lands[indexPath.row]

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
        guard let data = landmark.image else {
            ErrorHandler.Instance.handle(sender: self, error: .noLandmarkImageFound)
            return cell
        }
        DispatchQueue.main.async {
            cell.imageView?.image = UIImage(data: data)
            cell.setNeedsLayout()
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
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let landmark = lands[indexPath.row]
        
        let modifyAction = UIContextualAction(style: .normal, title: "Modifier") { [weak self]_, _, completion in
            guard let self = self else {
                return
            }
            self.performSegue(withIdentifier: "createLandmarkSegue", sender: landmark)
            
        }
        
        let swipeActionConfiguration = UISwipeActionsConfiguration(actions: [modifyAction])
        
        return swipeActionConfiguration
    }
    
}

//MARK: - Extensions

extension LandsViewController : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchQuery = searchController.searchBar.text
        
        guard let category = category else {
            ErrorHandler.Instance.handle(sender: self, error: .noCategoryFound)
            return
        }
        
        lands = CoreDataManager.Instance.fetchLandmarks(searchQuery: searchQuery, filter: currentFilter, category: category)
        
        tableView.reloadData()
    }
    
}

extension LandsViewController : LandsDelegate {
    
    func updateLand(_ controller: CreateLandViewController, landmark: Landmark) {
        guard let category = category else {
            ErrorHandler.Instance.handle(sender: self, error: .noCategoryFound)
            return
        }
        
        lands = CoreDataManager.Instance.fetchLandmarks(filter: currentFilter, category: category)
        tableView.reloadData()
        
        controller.dismiss(animated: true)
    }
    
    
    func addLand(_ controller: CreateLandViewController) {
        
        guard let category = category else {
            ErrorHandler.Instance.handle(sender: self, error: .noCategoryFound)
            return
        }
        
        lands = CoreDataManager.Instance.fetchLandmarks(filter: currentFilter, category: category)
        tableView.reloadData()
        
        controller.dismiss(animated: true)
    }
        
}
