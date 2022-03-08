//
//  CreateLandViewController.swift
//  PlaceManager
//
//  Created by lpiem on 16/02/2022.
//

import UIKit
import PhotosUI
import MapKit

class CreateLandViewController : UIViewController, PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        let itemProvider = results.first?.itemProvider
        
        if let itemProvider = itemProvider , itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                guard let self = self else {return}
                guard let image = image as? UIImage else{return}
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
                
            }
        }
        
    }
    
    var category : Category? = nil
    
    private var coordinates : CLLocationCoordinate2D? = nil
    @IBOutlet weak var desc: UITextField!
    @IBOutlet weak var landmarkTitle: UITextField!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var imageView: UIImageView!
    private var configuration = PHPickerConfiguration()
    internal var imagePicker : PHPickerViewController? = nil
    
    var landsDelegate : LandsDelegate? = nil
    var landToModify : Landmark? = nil
    
    override func viewDidLoad() {
        
        if let landToModify = landToModify {
            guard let image = landToModify.image else {
                ErrorHandler.Instance.handle(sender: self, error: .noLandmarkImageFound)
                return
            }
            guard let coordinates = landToModify.coordinates else {
                ErrorHandler.Instance.handle(sender: self, error: .noLandmarkCoordinatesFound)
                return
            }
            
            landmarkTitle.text = landToModify.title
            desc.text = landToModify.desc
            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: image)
            }
            map.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude), latitudinalMeters: 10 * 1000, longitudinalMeters: 10 * 1000)
            category = landToModify.category
        }
        configuration.filter = .any(of: [.images, .livePhotos])
        configuration.selectionLimit = 1
        imagePicker = PHPickerViewController(configuration: configuration)
        imagePicker?.delegate = self
        map.delegate = self
        address.text = "\(map.centerCoordinate.latitude) \(map.centerCoordinate.longitude)"
        coordinates = map.centerCoordinate
        
    }
    
    @IBAction func save() {
        guard let category = category else {
            ErrorHandler.Instance.handle(sender: self, error: .noCategoryFound)
            return
        }
        guard let ldTitle = landmarkTitle.text else {
            ErrorHandler.Instance.handle(sender: self, error: .noLandmarkTitleFound, doDismiss: false)
            return
        }
        guard let ldDesc = desc.text else {
            ErrorHandler.Instance.handle(sender: self, error: .noLandmarkDescriptionFound, doDismiss: false)
            return
        }
        guard let image = imageView.image else {
            ErrorHandler.Instance.handle(sender: self, error: .noLandmarkImageFound, doDismiss: false)
            return
        }
        guard let coordinates = coordinates else {
            ErrorHandler.Instance.handle(sender: self, error: .noLandmarkCoordinatesFound, doDismiss: false)
            return
        }
        guard let delegate = landsDelegate else {
            ErrorHandler.Instance.handle(sender: self, error: .noDelegateFound)
            return
        }
        
        if (landmarkTitle.hasText ){
            
            if (desc.hasText) {
                if (imageView.image != nil) {
                    if let landToModify = landToModify {
                        
                        CoreDataManager.Instance.updateLandmark(landmark: landToModify, title: ldTitle, desc: ldDesc, image: image, coordinates: coordinates)
                        delegate.updateLand(self, landmark: landToModify)
                        
                    }
                    else {
                        
                        CoreDataManager.Instance.createLandmark(title: ldTitle, description: ldDesc, category: category, image: image, coordinates: coordinates)
                        delegate.addLand(self)
                        
                    }
                }
                else {
                    ErrorHandler.Instance.handle(sender: self, error: .noLandmarkImageFound, doDismiss: false)
                }
            }
            else{
                ErrorHandler.Instance.handle(sender: self, error: .noLandmarkDescriptionFound, doDismiss: false)
            }
        }
        else {
            ErrorHandler.Instance.handle(sender: self, error: .noLandmarkTitleFound, doDismiss: false)
        }
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectImage() {
        guard let imagePicker = imagePicker else {return}
            
        present(imagePicker, animated: true)
    }
    
}

extension CreateLandViewController : MKMapViewDelegate {
    func mapViewDidChangeVisibleRegion(_ mapView : MKMapView){
        address.text = "\(mapView.centerCoordinate.latitude) \(mapView.centerCoordinate.longitude)"
        coordinates = map.centerCoordinate
    }
    
}

protocol LandsDelegate {
    func addLand(_ controller: CreateLandViewController);
    func updateLand(_ controller: CreateLandViewController, landmark: Landmark);
}
