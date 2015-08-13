//
//  Photo.swift
//  VirtualTourist
//
//  Created by Samuel Doherty on 8/9/15.
//  Copyright (c) 2015 ColombiaIOS. All rights reserved.
//

import Foundation
import CoreData
import UIKit

@objc(Photo)

class Photo :NSManagedObject {
    
    @NSManaged var imagePath: String
    @NSManaged var pin: Pin
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    
    init(pin: Pin, dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        self.pin = pin
        self.imagePath = dictionary["id"] as! String
    }
    
    var locationImage: UIImage? {
        
        get {
            return PhotoClient.Caches.imageCache.imageWithIdentifier(imagePath)
        }
        
        set {
            PhotoClient.Caches.imageCache.storeImage(newValue, withIdentifier: imagePath)
        }
    }
    
}