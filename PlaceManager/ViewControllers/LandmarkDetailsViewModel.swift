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
        if let landmark = landmark {
            self.title = landmark.title
            if let data = landmark.image {
                image.image = UIImage(data: data)
            }
            image.layer.cornerRadius = 75.0
            image.layer.borderWidth = 2
            image.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 255)
            ldTitle.text = landmark.title
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .none
            
            if let created = landmark.created {
                ldCreated.text = "Created : \(dateFormatter.string(from: created))"
            }
            if let modified = landmark.modified {
                ldModified.text = "Modified : \(dateFormatter.string(from: modified))"
            }
            ldDescription.text = landmark.desc
        }
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true)
    }
}
