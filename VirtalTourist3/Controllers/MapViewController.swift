//
//  MapViewController.swift
//  VirtalTourist3
//
//  Created by Raghad Mah on 26/01/2019.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {
    
    //Variables
    var dataController: DataController!
    var fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
    var myPin: Pin!
    
    //Outlets
    @IBOutlet var mapView: MKMapView!
    
    
    //MARK: viewDidLoad & viewWillAppear
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupFetchedResultsController()
        // check long press and do an action through selector
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.handleLongPress(_:)))
        longPressRecogniser.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPressRecogniser)
        
        print(myPin)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
    }
    
    
    // MARK: Handling Long Press func
    @objc func handleLongPress(_ gestureRecognizer : UIGestureRecognizer){
        if gestureRecognizer.state != .began { return }
        let touchPoint = gestureRecognizer.location(in: mapView)
        let coordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        createAnnotation(coordinate: coordinates)
    }
    
    func createAnnotation(coordinate: CLLocationCoordinate2D){
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        let newPin = Pin(context: dataController.viewContext)
        newPin.latitude = coordinate.latitude
        newPin.longitude = coordinate.longitude
        do{
            try dataController.viewContext.save()
            myPin = newPin
        } catch{
            debugPrint()
        }
        mapView.addAnnotation(annotation)
    }
    
    // MARK: SetupFetchedResultsController
    func setupFetchedResultsController() {
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            for pin in result {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(pin.latitude), longitude: CLLocationDegrees(pin.longitude))
                mapView.addAnnotation(annotation)
            }
        }
    }
    
    
    // MARK: PrepareForSegue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photoCollectionSegue"{
            let vc = segue.destination as! PhotosCollectionViewController
            vc.pin = myPin
        }
    }
    
    
    //MARK: mapView functions
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard annotation is MKPointAnnotation else { print("no mkpointannotaions"); return nil }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.rightCalloutAccessoryView = UIButton(type: .infoDark)
            pinView!.pinTintColor = UIColor.red
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        //Assigning latitude and longitude
        if let alatitude = view.annotation?.coordinate.latitude , let alongitude = view.annotation?.coordinate.longitude {
            if let result = try? dataController.viewContext.fetch(fetchRequest) {
                for pin in result {
                    if pin.latitude == alatitude && pin.longitude == alongitude {
                        myPin = pin
                        self.performSegue(withIdentifier: "photoCollectionSegue", sender: nil)
                    }
                    
                }
            }
        }
    }
}

