//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Samuel Doherty on 8/8/15.
//  Copyright (c) 2015 ColombiaIOS. All rights reserved.
//

import UIKit
import MapKit
import CoreData


class ViewController: UIViewController, MKMapViewDelegate{
    
    
    @IBOutlet weak var mapView: MKMapView!
    var mapPins = [Pin]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        var gensture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "action:")
        
        gensture.minimumPressDuration = 1.0
        self.mapView.addGestureRecognizer(gensture)
        
        mapPins = fetchAllPins()
        
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        let reuseId = "pin"
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView.canShowCallout = false
        return pinView
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        let ant = view.annotation as! MKPointAnnotation
        var photoAlbumVC = storyboard?.instantiateViewControllerWithIdentifier("PhotoAlbumVC") as! PhotoAlbumViewController
        let error:NSErrorPointer = nil
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        let firstPredicate = NSPredicate(format: "lat == %@", ant.coordinate.latitude)
        let SecondPredicate = NSPredicate(format: "long == %@",ant.coordinate.longitude)
        let predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [firstPredicate, SecondPredicate])
        
        fetchRequest.predicate = predicate
        
        let results = sharedContext.executeFetchRequest(fetchRequest, error: error)
        println(results)
        
        if error != nil {
            println("Error in fetchpin():\(error)")
        }
    
//        photoAlbumVC.mapPin = 
        presentViewController(photoAlbumVC, animated: true, completion: nil)
    }
    
    func action(gestureRecognizer:UIGestureRecognizer){
        var touchPoint = gestureRecognizer.locationInView(mapView)
        var newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoordinates
        mapView.addAnnotation(annotation)
        
        let mapPin = Pin(location: newCoordinates, context: self.sharedContext)
        let parameters :[String:AnyObject] = ["lat":"\(mapPin.lat)", "lon":"\(mapPin.long)"]
        PhotoClient.sharedInstance().GetResource(parameters) { [unowned self] jsonResult, error in
            
            // Handle the error case
            if let error = error {
                println("Error searching for actors: \(error.localizedDescription)")
                return
            }
            
            // Get a Swift dictionary from the JSON data
            if let photosDictionaries = jsonResult.valueForKey("photos") as? [String : AnyObject] {
                if let photoDictionary = photosDictionaries["photo"] as? [[String : AnyObject]] {
                    var photos = photoDictionary.map() {
                      Photo(pin: mapPin, dictionary: $0, context: self.sharedContext)
                    }
                    var error:NSError? = nil
                    
                    self.sharedContext.save(&error)
            
                    
                    if let error = error {
                        println("error saving context: \(error.localizedDescription)")
                    }
                }
            }
        }
       
     
    }
    
    func insertNewObject(pin:Pin) {
        dispatch_async(dispatch_get_main_queue()) {
            self.mapPins.append(pin)
        
            var error:NSError? = nil
            
            self.sharedContext.save(&error)
            
            if let error = error {
                println("error saving context: \(error.localizedDescription)")
            }
        }
    }
    
    // Step 2: Add a fetchAllEvents() method
    // (See the fetchAllActors() method in FavoriteActorViewController for an example
    func fetchAllPins() -> [Pin] {
        let error:NSErrorPointer = nil
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        
        let results = sharedContext.executeFetchRequest(fetchRequest, error: error)
        
        if error != nil {
            println("Error in fetchAllPins():\(error)")
        }
        return results as! [Pin]
    }
    
    
    // Alert view
    func alert(text:String) {
        let alertView = UIAlertView()
        alertView.message = text
        alertView.addButtonWithTitle("Ok")
        alertView.show()
    }
    
    
}

