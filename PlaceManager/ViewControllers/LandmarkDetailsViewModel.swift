//
//  LandmarkDetailsViewModel.swift
//  PlaceManager
//
//  Created by lpiem on 16/02/2022.
//

import UIKit
import PhotosUI
import MapKit

class LandmarkDetailsViewModel : UIViewController {
    
    @IBOutlet weak var ldCreated: UILabel!
    @IBOutlet weak var ldTitle: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var ldModified: UILabel!
    @IBOutlet weak var ldDescription: UILabel!
    var landmark : Landmark? = nil
    
    override func viewDidLoad() {
        guard let landmark = landmark else {
            ErrorHandler.Instance.handle(sender: self, error: .noLandmarkFound)
            return
        }
        initView(landmark: landmark)
    }
    
    private func initView(landmark : Landmark){
        guard let data = landmark.image else {
            ErrorHandler.Instance.handle(sender: self, error: .noLandmarkImageFound)
            return
        }
        guard let created = landmark.created else {
            ErrorHandler.Instance.handle(sender: self, error: .noCategoryFound)
            return
        }
        guard let modified = landmark.modified else {
            ErrorHandler.Instance.handle(sender: self, error: .noCategoryFound)
            return
        }
        guard let coordinates = landmark.coordinates else {
            ErrorHandler.Instance.handle(sender: self, error: .noLandmarkCoordinatesFound)
            return
        }
        
        self.title = landmark.title
        DispatchQueue.main.async {
            self.image.image = UIImage(data: data)
        }
        image.layer.cornerRadius = 75.0
        image.layer.borderWidth = 2
        image.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 255)
        ldTitle.text = landmark.title
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        
        ldCreated.text = "Created : \(dateFormatter.string(from: created))"
        ldModified.text = "Modified : \(dateFormatter.string(from: modified))"
        
        ldDescription.text = landmark.desc
        
        map.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude), latitudinalMeters: 10 * 1000, longitudinalMeters: 10 * 1000)
        map.isUserInteractionEnabled = false
    }
    
    
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch (segue.identifier){
        case "modifyLandmarkSegue":
            guard let navigationController = segue.destination as? UINavigationController,
                  let destination = navigationController.children[0] as? CreateLandViewController
            else {
                ErrorHandler.Instance.handle(sender: self, error: .navigationError)
                return
            }
            destination.landToModify = self.landmark
            destination.landsDelegate = self
            
        default:
            return
        }
    }
}

extension LandmarkDetailsViewModel : LandsDelegate {
    func addLand(_ controller: CreateLandViewController) {
        //DO NOTHING
    }
    
    func updateLand(_ controller: CreateLandViewController, landmark: Landmark) {
        self.landmark = landmark
        
        guard let landmark = self.landmark else {
            ErrorHandler.Instance.handle(sender: self, error: .noLandmarkFound)
            return
        }
        initView(landmark: landmark)
        
        controller.dismiss(animated: true)
    }
    
}
