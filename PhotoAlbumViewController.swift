//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Samuel Doherty on 8/9/15.
//  Copyright (c) 2015 ColombiaIOS. All rights reserved.
//

import UIKit
import MapKit
import CoreData


class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, MKMapViewDelegate {

    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var album: UICollectionView!
   
    var mapPin: Pin?
    var photos = [Photo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var span = MKCoordinateSpanMake(3, 3)
     
        let annotation = MKPointAnnotation()
        let cord = CLLocationCoordinate2D(latitude: Double(mapPin!.lat), longitude: Double(mapPin!.long))
        annotation.coordinate = cord
        
        var region = MKCoordinateRegion(center: cord, span: span)
        map.setRegion(region, animated: true)
        map.addAnnotation(annotation)
        
        self.photos = mapPin?.photos?.array as! [Photo]
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    // MARK: - UICollectionView
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCell
        cell.activityView.hidesWhenStopped = true
        
        var photo = photos[indexPath.row]
        
        if photo.locationImage == nil {
            cell.image.image = UIImage(named: "DefaultPhoto")
            cell.activityView.startAnimating()
            
            //get image
            let imageURL = NSURL(string: photo.imagePath)
            let imageData = NSData(contentsOfURL: imageURL!)
            let pic = UIImage(data: imageData!)
            
            cell.activityView.stopAnimating()
            cell.image.image = pic
            photo.locationImage = pic
            
            // save in core data
            var error:NSError? = nil
            self.sharedContext.save(&error)
            
            if let error = error {
                println("error saving context: \(error.localizedDescription)")
            }
           
        } else {
            cell.image.image = photos[indexPath.row].locationImage
        }
//        album.reloadData()

        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
       let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCell
        
//        // Whenever a cell is tapped we will toggle its presence in the selectedIndexes array
//        if let index = find(selectedIndexes, indexPath) {
//            selectedIndexes.removeAtIndex(index)
//        } else {
//            selectedIndexes.append(indexPath)
//        }
//        
//        // Then reconfigure the cell
//        configureCell(cell, atIndexPath: indexPath)
//        
//        // And update the buttom button
//        updateBottomButton()
    }
    
    @IBAction func closeView(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }


    @IBAction func loadMoreImages(sender: UIButton) {
    }
    
//    func loadPhotos() -> [Photo] {
//        
//    }

}
