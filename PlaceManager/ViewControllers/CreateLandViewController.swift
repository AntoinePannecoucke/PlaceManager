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
        
        if let itemProvider = itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                guard let self = self else {return}
                if let image = image as? UIImage{
                    DispatchQueue.main.async {
                        self.imageView.image = image
                    }
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
    
    override func viewDidLoad() {
        configuration.filter = .any(of: [.images, .livePhotos])
        configuration.selectionLimit = 1
        imagePicker = PHPickerViewController(configuration: configuration)
        imagePicker?.delegate = self
        map.delegate = self
        address.text = "\(map.centerCoordinate.latitude) \(map.centerCoordinate.longitude)"
        coordinates = map.centerCoordinate
    }
    
    @IBAction func save() {
        if (landmarkTitle.hasText && desc.hasText && imageView.image != nil ){
            if let category = category, let ldTitle = landmarkTitle.text, let ldDesc = desc.text, let image = imageView.image, let coordinates = coordinates {
                CoreDataManager.Instance.createLandmark(title: ldTitle, description: ldDesc, category: category, image: image, coordinates: coordinates)
                dismiss(animated: true)
            }
        }
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectImage() {
        guard let imagePicker = imagePicker else {
            return
        }
        
        present(imagePicker, animated: true)
    }
    
    func saveCoordinates() {
        
    }
}

extension CreateLandViewController : MKMapViewDelegate {
    func mapViewDidChangeVisibleRegion(_ mapView : MKMapView){
        address.text = "\(mapView.centerCoordinate.latitude) \(mapView.centerCoordinate.longitude)"
        coordinates = map.centerCoordinate
    }
    
}
