//
//  MapPin.swift
//  VirtualTourist
//
//  Created by Samuel Doherty on 8/9/15.
//  Copyright (c) 2015 ColombiaIOS. All rights reserved.
//

import Foundation
import CoreData
import MapKit

@objc(Pin)

class Pin: NSManagedObject {
    @NSManaged var lat : NSNumber
    @NSManaged var long: NSNumber
    @NSManaged var photos: [Photo]?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(location:CLLocationCoordinate2D, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        lat = location.latitude as Double
        long = location.longitude as Double

    }
}
