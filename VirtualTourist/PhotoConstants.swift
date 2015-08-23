//
//  PhotoConstants.swift
//  VirtualTourist
//
//  Created by Samuel Doherty on 8/10/15.
//  Copyright (c) 2015 ColombiaIOS. All rights reserved.
//

import Foundation

extension PhotoClient {
    // MARK: - Constants
    struct Constants {
        // MARK: API Key
        static let ApiKey : String = "982f17eedba934b9c72f538c01c8aa8c"
        static let ApiSecret : String = "909f0a4f02b7ba68"

        // MARK: URLs
        static let BaseURLSecure : String = "https://api.flickr.com/services/rest/"
        static let BaseURLImage : String = "https://farm"
    }
    
    // MARK: - Methods
    struct Methods {
        static let Api_Key = "api_key"
        static let Accuracy = "11"
        static let Nojsoncallback = "nojsoncallback"
        static let FlickrMethod = "flickr.photos.search"
        static let Format = "json"
        static let PhotoLimit = "21"
        
    }
    
    // MARK: - JSON Resonse Keys
    struct JSONResponseKeys {
        static let farm = "farm"
        static let server = "server"
        static let id = "id"
        static let secret = "secret"
        
    }
}