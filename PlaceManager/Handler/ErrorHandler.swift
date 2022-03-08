//
//  ErrorHandler.swift
//  PlaceManager
//
//  Created by lpiem on 08/03/2022.
//

import UIKit

class ErrorHandler {
    static let Instance = ErrorHandler();
    
    func handle(sender: UIViewController, error: ErrorHandled, doDismiss : Bool = true){
        let alertController = UIAlertController(title: "Error", message: error.rawValue, preferredStyle: .alert)
        let neutralAction = UIAlertAction(title: "OK",
                                          style: .default)
        { _ in
            if (doDismiss){
                sender.dismiss(animated: true)
            }
        }
        alertController.addAction(neutralAction)
        
        sender.present(alertController, animated: true)
    }
}

enum ErrorHandled : String {
    case fieldDidNotExists = "Field used did not exists !"
    case indexPathNotExists = "Index path searched not exists !"
    case navigationError = "Error occure during segue…"
    case noCategoryFound = "No category found !"
    case noDelegateFound = "No delegate found !"
    case noLandmarkFound = "No landmark found !"
    case noLandmarkTitleFound = "No landmark's title found !"
    case noLandmarkDescriptionFound = "No landmark's description found !"
    case noLandmarkCoordinatesFound = "No landmark's coordinates found !"
    case noLandmarkImageFound = "No landmark's image found !"
    case noLandmarkCreatedDateFound = "No landmark's created date found !"
    case noLandmarkModifiedDateFound = "No landmark's modified date found !"
}
