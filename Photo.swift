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
    @NSManaged var imageURL: String
    @NSManaged var pin: Pin
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(pin: Pin, dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        self.pin = pin
        var farm = dictionary["farm"] as! Int
        var server = dictionary["server"] as! String
        var id = dictionary["id"] as! String
        var secret = dictionary["secret"] as! String
        var url = "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg"
        self.imagePath = url.lastPathComponent
        self.imageURL = url
    }
    
    var locationImage: UIImage? {
        
        get {
            return PhotoClient.Caches.imageCache.imageWithIdentifier(imagePath)
        }
        
        set {
            PhotoClient.Caches.imageCache.storeImage(newValue, withIdentifier: imagePath)
        }
    }
    
    //Delete the associated image file when the Photo managed object is deleted.
    override func prepareForDeletion() {
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        let pathArray = [dirPath, imagePath]
        let fileURL = NSURL.fileURLWithPathComponents(pathArray)!
        NSFileManager.defaultManager().removeItemAtURL(fileURL, error: nil)

    }
    
}