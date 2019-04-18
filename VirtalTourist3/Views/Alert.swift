//
//  Alert+ActivityIndicator.swift
//  VirtalTourist3
//
//  Created by Raghad Mah on 03/02/2019.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation
import UIKit

//MARK: Alert
extension UIViewController{
     func showAlert(message: String, vc: UIViewController){
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alert.addAction(action)
        
        vc.present(alert, animated: true, completion: nil)
    }
}

