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
    
    // IBOutlets
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var album: UICollectionView!
   
    // Instance variables
    var mapPin: Pin?
    var photos = [Photo]()
    var downloadingCount = 0
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // set map location and region
        loadMapLocation()
        
        // set photos array
        self.photos = mapPin?.photos?.array as! [Photo]
    }
    
    // MARK: - Core data
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    // MARK: - UICollectionView
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    //pull image from flickr for each Photo in the photos array
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCell
        cell.activityView.hidesWhenStopped = true
        
        var photo = photos[indexPath.row]

        if photo.locationImage != nil {
            cell.image.image = photo.locationImage
        } else {
            cell.image.image = UIImage(named: "DefaultPhoto")
            cell.activityView.startAnimating()
            dispatch_async(dispatch_get_main_queue()) {
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
                    self.alert("Error saving image")
                }
                
                
            }
        }
        
        return cell
    }
    
    // delete image when image is selected
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCell

        let photo = photos[indexPath.row]
        photos.removeAtIndex(indexPath.row)
        album.deleteItemsAtIndexPaths([indexPath])
        self.sharedContext.deleteObject(photo)
        var error:NSError? = nil
        
        self.sharedContext.save(&error)
        
        if let error = error {
            println("error saving context: \(error.localizedDescription)")
            self.alert("Error saving deletion")
        }
    }
    

    
    // MARK: - IBActions
    @IBAction func closeView(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    // load next page of images from flickr
    @IBAction func loadMoreImages(sender: UIButton) {
        
        //Delete current photos
        deleteAllPictures()
        
        //Cycle through page numbers
        var pageNumber = Int(self.mapPin!.page!.integerValue)
        var totalPages = Int(self.mapPin!.pages!.integerValue)
        pageNumber++
        if pageNumber >= totalPages {
            mapPin!.page! = NSNumber(longLong:Int64(0))
            pageNumber = 0
        } else {
            mapPin!.page! = NSNumber(longLong: Int64(pageNumber))
        }
        
        let parameters :[String:AnyObject] = ["lat":"\(self.mapPin!.lat)", "lon":"\(self.mapPin!.long)", "page": String(pageNumber)]
        
        PhotoClient.sharedInstance().GetResource(parameters) { [unowned self] jsonResult, error in
            
            // Handle the error case
            if let error = error {
                println("Error getting for images: \(error.localizedDescription)")
                self.alert("Error getting images from flickr")
                return
            }
            
            // Get a Swift dictionary from the JSON data
            if let photosDictionaries = jsonResult.valueForKey("photos") as? [String : AnyObject] {
                if let maxPages = photosDictionaries["pages"] as? NSNumber {
                    self.mapPin!.pages = maxPages
                }
                if let pageNumber = photosDictionaries["page"] as? NSNumber {
                    self.mapPin!.page = pageNumber
                }
                if let photoDictionary = photosDictionaries["photo"] as? [[String : AnyObject]] {
                    var photos = photoDictionary.map() {
                        Photo(pin: self.mapPin!, dictionary: $0, context: self.sharedContext)
                    }
                    
                    self.photos = photos
                    
                    var error:NSError? = nil
                    
                    self.sharedContext.save(&error)
                    
                    if let error = error {
                        println("error saving context: \(error.localizedDescription)")
                        self.alert("Error saving images")
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        self.album.reloadData()
                    }
                }
            }
        }
    }
    // MARK: - Helper function
    
    // Alert view
    func alert(text:String) {
        let alertView = UIAlertView()
        alertView.message = text
        alertView.addButtonWithTitle("Ok")
        alertView.show()
    }
    
    // Load map locations
    func loadMapLocation(){
        var span = MKCoordinateSpanMake(3, 3)
        let annotation = MKPointAnnotation()
        let cord = CLLocationCoordinate2D(latitude: Double(mapPin!.lat), longitude: Double(mapPin!.long))
        annotation.coordinate = cord
        var region = MKCoordinateRegion(center: cord, span: span)
        map.setRegion(region, animated: true)
        map.addAnnotation(annotation)
    }
    
    // Delete all images in photos array
    func deleteAllPictures() {
        for photo in self.photos {
            self.sharedContext.deleteObject(photo)
        }
        self.photos = [Photo]()
        var error:NSError? = nil
        
        self.sharedContext.save(&error)
        
        if let error = error {
            println("error saving context: \(error.localizedDescription)")
            self.alert("Error saving deletes")
        }
    }
}
