//
//  PhotosCollectionExtra.swift
//  VirtalTourist3
//
//  Created by Raghad Mah on 26/01/2019.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation
import MapKit
import CoreData

extension PhotosCollectionViewController: MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    
    //MARK: collectionView setup
    //number of SECTIONS
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //number of ITEMS in section
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return fetchedResultsController.fetchedObjects!.count
    }
    
    //cell for item AT
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCollectionCell", for: indexPath) as! PhotosCollectioViewCell
        
        
        let photo = fetchedResultsController.object(at: indexPath)
        
        if let data = photo.imageData {
            cell.image.image = UIImage(data: data)
        } else {
            activityIndicator(cell: cell, status: true)
            cell.contentView.alpha = 1.0
            
            downloadImage(imagePath: photo.url!) { imageData, errorString in
                if let imageData = imageData {
                    DispatchQueue.main.async {
                        self.activityIndicator(cell: cell, status: false)
                        cell.image.image = UIImage(data: imageData)
                    }
                    photo.imageData = imageData
                    try? self.dataController.viewContext.save()
                }
            }
        }
        
        return cell
    }
    
    //did SELECT item at
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.contentView.alpha = 0.4
        
        if selectedPhotos.contains(indexPath) == false {
            selectedPhotos.append(indexPath)
        }
        selectPhotoActionButton()
    }
    
    //did DESELECT item at
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.contentView.alpha = 1.0
        
        if let index = selectedPhotos.firstIndex(of: indexPath) {
            selectedPhotos.remove(at: index)
        }
        selectPhotoActionButton()
    }
    
    //changes text color and text in updateCollection button
    func selectPhotoActionButton() {
        if hasSelectedPhotos() {
            toolbarButton.title = "Delete Selected Photos"
            toolbarButton.tintColor = .red
        }
        else {
            toolbarButton.title = "Update Collection"
            toolbarButton.tintColor = .blue
        }
    }
    
    //Checks if a photo is selected
    func hasSelectedPhotos() -> Bool {
        if selectedPhotos.count == 0 {
            return false
        }
        return true
    }
    
    //MARK: deleteSelectedPhotos
    func deleteSelectedPhotos() {
        let photos = selectedPhotos.map() { fetchedResultsController.object(at: $0) }
        photos.forEach() { photo in
            dataController.viewContext.delete(photo)
            selectedPhotos.removeAll()
            
            try? dataController.viewContext.save()
        }
        
        selectPhotoActionButton()
    }
    
    //MARK: activityIndicator func
    func activityIndicator(cell: PhotosCollectioViewCell, status: Bool){
        if status == true {
            cell.activityIndicator.startAnimating()
            cell.activityIndicator.isHidden = false
        }
        else {
            cell.activityIndicator.isHidden = true
            cell.activityIndicator.stopAnimating()
        }
        
    }
    
    //MARK: mapView setup
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    //MARK: controller func
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.collectionView.insertItems(at: [newIndexPath!])
            
        case .delete:
            self.collectionView.deleteItems(at: [indexPath!])
        case .move:
            self.collectionView.moveItem(at: indexPath!, to: newIndexPath!)
        case .update:
            self.collectionView.reloadItems(at: [indexPath!])
        }
    }
}

