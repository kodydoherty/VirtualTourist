//
//  PhotoClient.swift
//  VirtualTourist
//
//  Created by Samuel Doherty on 8/10/15.
//  Copyright (c) 2015 ColombiaIOS. All rights reserved.
//

import Foundation

class PhotoClient:NSObject {
   
    typealias CompletionHander = (result: AnyObject!, error: NSError?) -> Void
    
    private let session: NSURLSession
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // MARK: - Main Get method for flickr
    func GetResource(parameters: [String : AnyObject], completionHandler: CompletionHander) -> NSURLSessionDataTask {
        
        var mutableParameters = parameters
        
        // Add in the API Key and set paramaters
        mutableParameters["method"] = Methods.FlickrMethod
        mutableParameters["api_key"] = Constants.ApiKey
        mutableParameters["accuracy"] = Methods.Accuracy
        mutableParameters["lat"] = parameters["lat"] as! String
        mutableParameters["lon"] = parameters["lon"] as! String
        mutableParameters["per_page"] = Methods.PhotoLimit
        if let pageNumber = parameters["page"] as? String {
            mutableParameters["page"] = pageNumber
        }
        mutableParameters["format"] = Methods.Format
        mutableParameters["nojsoncallback"] = Methods.Nojsoncallback
        
        
        let urlString = PhotoClient.Constants.BaseURLSecure + PhotoClient.escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if let error = downloadError {
                completionHandler(result: nil, error: downloadError)
            } else {
                PhotoClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        
        task.resume()
        
        return task
    }

    
    // Parsing the JSON
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: CompletionHander) {
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    // URL Encoding a dictionary into a parameter string
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            // Make sure that it is a string value
            let stringValue = "\(value)"
            
            // Escape it
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            // Append it
            
            urlVars += [key + "=" + "\(escapedValue!)"]
        }
        
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
    
    // MARK: - Shared Instance
    class func sharedInstance() -> PhotoClient {
        
        struct Singleton {
            static let sharedInstance = PhotoClient()
        }
        return Singleton.sharedInstance
    }
    
    
    // MARK: - Shared Image Cache
    struct Caches {
        static let imageCache = ImageCache()
    }

}