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
    // IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    // instants variables
    var mapPins = [Pin]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // configure gesture
        var gensture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "action:")
        gensture.minimumPressDuration = 1.5
        self.mapView.addGestureRecognizer(gensture)
        
        // set region based on last location
        setRegionFromDefaults()
        
        // get all pins saved in core data
        fetchAllPins()
    }

    // MARK: - Core data shared context
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    // MARK: - Mapkit Methods
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        // Find the current map view span
        let lat = mapView.region.span.latitudeDelta
        let long = mapView.region.span.longitudeDelta
        
        // Find map view current center locaiton
        let centerx = mapView.region.center.latitude
        let centery = mapView.region.center.longitude
        
        // set defaults for the current map view locaiton
        NSUserDefaults.standardUserDefaults().setDouble(lat, forKey: "lat")
        NSUserDefaults.standardUserDefaults().setDouble(lat, forKey: "long")
        NSUserDefaults.standardUserDefaults().setDouble(Double(centerx), forKey: "centerx")
        NSUserDefaults.standardUserDefaults().setDouble(Double(centery), forKey: "centery")
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
        
        // get selected pins from core data
        let error:NSErrorPointer = nil
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        // core data search by lat and long
        let firstPredicate = NSPredicate(format: "lat == %@", NSNumber(double: ant.coordinate.latitude))
        let SecondPredicate = NSPredicate(format: "long == %@",NSNumber(double: ant.coordinate.longitude))
        let predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [firstPredicate, SecondPredicate])
        fetchRequest.predicate = predicate
        
        // search results
        let results = sharedContext.executeFetchRequest(fetchRequest, error: error)
        let pin = results as! [Pin]
        
        // Set pin
        photoAlbumVC.mapPin = pin[0]
        
        if error != nil {
            println("Error in fetchpin():\(error)")
        }
        
        presentViewController(photoAlbumVC, animated: true, completion: nil)
    }
    // MARK: - Gesture Reconizer
    // get all of the flickr photos by location
    func action(gestureRecognizer:UIGestureRecognizer){
        var touchPoint = gestureRecognizer.locationInView(mapView)
        var newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoordinates
        mapView.addAnnotation(annotation)
        let pageNumber:Int = 0
        let mapPin = Pin(location: newCoordinates, context: self.sharedContext)
        let parameters :[String:AnyObject] = ["lat":"\(mapPin.lat)", "lon":"\(mapPin.long)"]
        PhotoClient.sharedInstance().GetResource(parameters) { [unowned self] jsonResult, error in
            
            // Handle the error case
            if let error = error {
                println("Error searching for flickr photo: \(error.localizedDescription)")
                self.alert("Error searching for flickr photos ")
                return
            }
            
            // Get a Swift dictionary from the JSON data
            if let photosDictionaries = jsonResult.valueForKey("photos") as? [String : AnyObject] {
                
                // get total pages
                if let maxPages = photosDictionaries["pages"] as? NSNumber {
                    mapPin.pages = maxPages
                }
                
                // get current page number
                if let pageNumber = photosDictionaries["page"] as? NSNumber {
                    mapPin.page = pageNumber
                }
                if let photoDictionary = photosDictionaries["photo"] as? [[String : AnyObject]] {
                    // build Photo array
                    var photos = photoDictionary.map() {
                        Photo(pin: mapPin, dictionary: $0, context: self.sharedContext)
                    }
                    
                    var error:NSError? = nil
                    
                    self.sharedContext.save(&error)
                    
                    if let error = error {
                        self.alert("Error saving context")
                        println("error saving context: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    // MARK: - Helper functions
    // Get all of the pins from core data
    func fetchAllPins()  {
        let error:NSErrorPointer = nil
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        
        let results = sharedContext.executeFetchRequest(fetchRequest, error: error) as! [Pin]
        
        if error != nil {
            println("Error in fetchAllPins():\(error)")
            alert("Error getting Pin")
            return
        }
        // cycle through results and create a pin for each location
        for pin in results {
            let annotation = MKPointAnnotation()
            let core = CLLocationCoordinate2D(latitude: Double(pin.lat), longitude: Double(pin.long))
            annotation.coordinate = core
            mapView.addAnnotation(annotation)
        }
    }
    // Alert view
    func alert(text:String) {
        let alertView = UIAlertView()
        alertView.message = text
        alertView.addButtonWithTitle("Ok")
        alertView.show()
    }
    
    // Set current region
    func setRegionFromDefaults(){
        if let lat = NSUserDefaults.standardUserDefaults().objectForKey("lat") as? Double {
            if let long = NSUserDefaults.standardUserDefaults().objectForKey("long") as? Double {
                if let centerx = NSUserDefaults.standardUserDefaults().objectForKey("centerx") as? Double {
                    if let centery = NSUserDefaults.standardUserDefaults().objectForKey("centery") as? Double {
                        var span = MKCoordinateSpanMake(lat, long)
                        var center = CLLocationCoordinate2DMake(centerx, centery)
                        var region = MKCoordinateRegion(center: center, span: span)
                        self.mapView.setRegion(region, animated: true)
                        
                    }
                }
            }
        }
    }
    
    
    
}

