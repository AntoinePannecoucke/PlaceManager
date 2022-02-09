//
//  CoreDataManager.swift
//  PlaceManager
//
//  Created by lpiem on 09/02/2022.
//

import Foundation
import CoreData
import UIKit

class CoreDataManager {
    
    static let Instance = CoreDataManager()
    
    //MARK: - Properties
    private var container : NSPersistentContainer
    
    //MARK: - Init
    
    private init() {
        container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    }
    
    //MARK: - Methods
    
    private func saveContext() {
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    func fetchCategories(searchQuery: String? = nil, filter: Filter = .Name) -> [Category]{
        let fetchRequest = Category.fetchRequest()
        
        let sortDescriptor : NSSortDescriptor
        switch(filter){
        case .Name :
            sortDescriptor = NSSortDescriptor(keyPath: \Category.name, ascending: true)
            break
        case .Creation :
            sortDescriptor = NSSortDescriptor(keyPath: \Category.created, ascending: true)
            break
        case .Modification :
            sortDescriptor = NSSortDescriptor(keyPath: \Category.modified, ascending: true)
            break
        }
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let searchQuery = searchQuery, !searchQuery.isEmpty {
            let predicate = NSPredicate(format: "%K contains[cd] %@",
                                        argumentArray: [#keyPath(Category.name), searchQuery])
            fetchRequest.predicate = predicate
        }
        
        
        do {
            let result = try container.viewContext.fetch(fetchRequest)
            return result
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func createCategory(name: String){
        let category = Category(context: container.viewContext)
        category.name = name
        category.created = Date()
        category.modified = category.created
        saveContext()
    }

    func deleteCategory(category: Category){
        container.viewContext.delete(category)
    }
    
    func fetchLandmarks(searchQuery: String? = nil, filter: Filter = .Name) -> [Landmark]{
        let fetchRequest = Landmark.fetchRequest()
        
        let sortDescriptor : NSSortDescriptor
        switch(filter){
        case .Name :
            sortDescriptor = NSSortDescriptor(keyPath: \Landmark.title, ascending: true)
            break
        case .Creation :
            sortDescriptor = NSSortDescriptor(keyPath: \Landmark.created, ascending: true)
            break
        case .Modification :
            sortDescriptor = NSSortDescriptor(keyPath: \Landmark.modified, ascending: true)
            break
        }
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let searchQuery = searchQuery, !searchQuery.isEmpty {
            let predicate = NSPredicate(format: "%K contains[cd] %@",
                                        argumentArray: [#keyPath(Landmark.title), searchQuery])
            fetchRequest.predicate = predicate
        }
        
        
        do {
            let result = try container.viewContext.fetch(fetchRequest)
            return result
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func createLandmark(title: String,description: String, category: Category){
        let landmark = Landmark(context: container.viewContext)
        landmark.title = title
        landmark.created = Date()
        landmark.modified = landmark.created
        landmark.category = category
        saveContext()
    }
    
    func deleteLandmark(landmark: Landmark){
        container.viewContext.delete(landmark)
    }
}

enum Filter {
    case Name, Creation, Modification
}
