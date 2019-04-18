//
//  PhotosCollectionViewController.swift
//  VirtalTourist3
//
//  Created by Raghad Mah on 26/01/2019.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotosCollectionViewController: UIViewController {
    
    //IBOutlets
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var toolbarButton: UIBarButtonItem!
    
    
    //Variables
    var pin: Pin!
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Photos>!
    var selectedPhotos: [IndexPath]! = []
    
    
    //MARK: viewDidLoad & viewWillAppear functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        dataController = appDelegate.dataController
        
        collectionView.allowsMultipleSelection = true
        mapView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        createAnnotation()
        
        setupFetchedResultsController()
        if fetchedResultsController.fetchedObjects!.count == 0 {
            loadPhotos()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView?.reloadData()
    }
    
    
    //MARK: updateCollection action
    @IBAction func updateCollection(_ sender: Any) {
        if hasSelectedPhotos() {
            deleteSelectedPhotos()
        } else {
            fetchedResultsController.fetchedObjects?.forEach() { photo in
                dataController.viewContext.delete(photo)
                do {
                    try dataController.viewContext.save()
                } catch {
                    self.showAlert(message: "Unable to delete photo", vc: self)
                    print("Unable to delete photo. \(error.localizedDescription)")
                }
            }
            self.collectionView.reloadData()
            loadPhotos()
        }
        
        try? dataController.viewContext.save()
    }
    
    
    //MARK: createAnnotation func
    func createAnnotation(){
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(pin.latitude, pin.longitude)
        mapView.addAnnotation(annotation)
        
        //zooming to location
        let coredinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(pin.latitude, pin.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: coredinate, span: span)
        
        self.mapView.isZoomEnabled = false;
        self.mapView.isScrollEnabled = false;
        self.mapView.isUserInteractionEnabled = false;
        
        mapView.setRegion(region, animated: true)
        
        
    }
    
    //MARK: setupFetchedResultsController func
    func setupFetchedResultsController() {
        
        let fetchRequest:NSFetchRequest<Photos> = Photos.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = []
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        //from controller func
        fetchedResultsController.delegate = self
        
        do{
            try fetchedResultsController.performFetch()
        }catch{
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    
    //MARK: loadPhotos func
    func loadPhotos() {
        
        let flickrCall = Requests.sharedInstance
        
        flickrCall.getPhotosforLocation(pin.latitude, pin.longitude, 20) { (success, photos) in
            
            if success == false {
                
                print("Unable to download images from Flickr.")
                self.showAlert(message: "Unable to download images from Flickr", vc: self)
                return
            }
            
            if photos!.count == 0 {
                self.showAlert(message: "No images found", vc: self)
                self.toolbarButton.isEnabled = false
            }
            else {
                print("Flickr images fetched : \(photos!.count)")
            }
            
            photos!.forEach() { photo_url in
                let photo = Photos(context: self.dataController.viewContext)
                photo.url = URL(string: photo_url["url_m"] as! String)?.absoluteString
                photo.pin = self.pin
                
                do {
                    // Saves to CoreData
                    try self.dataController.viewContext.save()
                } catch  {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    
    // MARK: downloadImage func
    func downloadImage( imagePath:String, completionHandler: @escaping (_ imageData: Data?, _ errorString: String?) -> Void){
        
        //2&3. Create session make the request
        let imgURL = NSURL(string: imagePath)
        let request: NSURLRequest = NSURLRequest(url: imgURL! as URL)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {data, response, downloadError in
            
            if downloadError != nil {
                completionHandler(nil, "Could not download image \(imagePath)")
            } else {
                
                //returning photos
                completionHandler(data, nil)
            }
        }
        task.resume()
    }
    
}
