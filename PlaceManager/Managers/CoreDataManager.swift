//
//  CoreDataManager.swift
//  PlaceManager
//
//  Created by lpiem on 09/02/2022.
//

import Foundation
import CoreData
import UIKit
import MapKit

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
        case .Creation :
            sortDescriptor = NSSortDescriptor(keyPath: \Category.created, ascending: true)
        case .Modification :
            sortDescriptor = NSSortDescriptor(keyPath: \Category.modified, ascending: true)
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
        saveContext()
    }
    
    func fetchLandmarks(searchQuery: String? = nil, filter: Filter = .Name, category: Category) -> [Landmark]{
        let fetchRequest = Landmark.fetchRequest()
        
        let sortDescriptor : NSSortDescriptor
        switch(filter){
        case .Name :
            sortDescriptor = NSSortDescriptor(keyPath: \Landmark.title, ascending: true)
        case .Creation :
            sortDescriptor = NSSortDescriptor(keyPath: \Landmark.created, ascending: true)
        case .Modification :
            sortDescriptor = NSSortDescriptor(keyPath: \Landmark.modified, ascending: true)
        }
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let searchQuery = searchQuery, !searchQuery.isEmpty {
            let predicate = NSCompoundPredicate (type: .and, subpredicates: [
                NSPredicate(format: "%K == %@", argumentArray: [#keyPath(Landmark.category), category]),
                NSPredicate(format: "%K contains[cd] %@", argumentArray: [#keyPath(Landmark.title), searchQuery])
            ])
            fetchRequest.predicate = predicate
        }
        else {
            fetchRequest.predicate = NSPredicate(format: "%K == %@", argumentArray: [#keyPath(Landmark.category), category])
        }
        
        
        do {
            let result = try container.viewContext.fetch(fetchRequest)
            return result
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func createLandmark(title: String, description: String, category: Category, image: UIImage, coordinates: CLLocationCoordinate2D){
        let landmark = Landmark(context: container.viewContext)
        landmark.title = title
        landmark.desc = description
        landmark.created = Date()
        landmark.modified = landmark.created
        landmark.image = image.pngData()
        landmark.coordinates = createCoordinates(coordinates: coordinates)
        landmark.category = category
        saveContext()
    }
    
    private func createCoordinates(coordinates: CLLocationCoordinate2D) -> Coordinates {
        let coord = Coordinates(context: container.viewContext)
        coord.latitude = coordinates.latitude
        coord.longitude = coordinates.longitude
        
        return coord
    }
    
    func deleteLandmark(landmark: Landmark){
        container.viewContext.delete(landmark)
        saveContext()
    }
    
    func updateLandmark(landmark: Landmark, title : String?, desc : String?, image: UIImage?, coordinates: CLLocationCoordinate2D?){
        if let title = title {
            landmark.setValue(title, forKey: #keyPath(Landmark.title))
        }
        if let desc = desc {
            landmark.setValue(desc, forKey: #keyPath(Landmark.desc))
        }
        if let image = image {
            landmark.setValue(image.pngData(), forKey: #keyPath(Landmark.image))
        }
        
        landmark.setValue(Date(), forKey: #keyPath(Landmark.modified))
        
        if let coordinates = coordinates {
            if let landmarkCoordinates = landmark.coordinates {
                updateCoordinates(coord: landmarkCoordinates, coordinates: coordinates)
            }
            else {
                landmark.coordinates = createCoordinates(coordinates: coordinates)
            }
        }
        
        saveContext()
    }
    
    func updateCoordinates(coord : Coordinates, coordinates: CLLocationCoordinate2D){
        coord.setValue(coordinates.latitude, forKey: #keyPath(Coordinates.latitude))
        coord.setValue(coordinates.longitude, forKey: #keyPath(Coordinates.longitude))
    }
}


enum Filter {
    case Name, Creation, Modification
}

