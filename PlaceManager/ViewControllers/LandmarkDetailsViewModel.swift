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
    
    var landmark : Landmark? = nil
    
    override func viewDidLoad() {
        if let landmark = landmark {
            self.title = landmark.title
        }
    }
    
}
