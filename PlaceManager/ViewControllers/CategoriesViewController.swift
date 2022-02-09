//
//  CategoriesViewController.swift
//  PlaceManager
//
//  Created by lpiem on 09/02/2022.
//

import UIKit

class CategoriesViewController : UITableViewController {
    
    //MARK: - Properties
    
    private let CellIdentifier = "categoryCell"
    private var categories : [Category] = []
    @IBOutlet weak var filterPullDownButton: UIButton!
    private var currentFilter = Filter.Name
    
    //MARK: - Lifecycle
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        
        categories = CoreDataManager.Instance.fetchCategories(filter: currentFilter)
        
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
        categories = CoreDataManager.Instance.fetchCategories(filter: currentFilter)
        tableView.reloadData()
    }

    //MARK: - User Actions
    
    @IBAction func createCategoryActionButton(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Create", message: "Create new Category", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Titre…"
        }
        
        let cancelAction = UIAlertAction(title: "Annuler",
                                         style: .cancel,
                                         handler: nil)
        
        let saveAction = UIAlertAction(title: "Sauvegarder",
                                       style: .default) { [weak self]_ in
           
            guard let self = self ,
                  let textField = alertController.textFields?.first else {
                return
            }
            
            if let categoryName = textField.text, !categoryName.isEmpty {
                CoreDataManager.Instance.createCategory(name: categoryName)
                self.categories = CoreDataManager.Instance.fetchCategories(filter: self.currentFilter)
                self.tableView.reloadData()
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        present(alertController, animated: true)
    }
    
    //MARK: - TableView Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath)
        let category = categories[indexPath.row]
        
        cell.textLabel?.text = category.name
        cell.detailTextLabel?.text = DateFormatter.localizedString(from: category.created!,
                                                               dateStyle: .short,
                                                               timeStyle: .short)
                
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let item = categories[indexPath.row]
        
        //TODO: Nav
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let category = categories[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Supprimer") { [weak self]_, _, completion in
            guard let self = self else {
                return
            }
            
            CoreDataManager.Instance.deleteCategory(category: category)
            self.categories.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
        }
        
        let swipeActionConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
        
        return swipeActionConfiguration
    }
    
}

//MARK: - Extensions
extension CategoriesViewController : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchQuery = searchController.searchBar.text
        categories = CoreDataManager.Instance.fetchCategories(searchQuery: searchQuery, filter: currentFilter)
        tableView.reloadData()
    }
    
}
