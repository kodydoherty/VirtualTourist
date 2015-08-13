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
    
    var session: NSURLSession
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // MARK: - All purpose task method for data
    
    func GetResource(parameters: [String : AnyObject], completionHandler: CompletionHander) -> NSURLSessionDataTask {
        
        var mutableParameters = parameters
        
        // Add in the API Key
        mutableParameters["method"] = Methods.FlickrMethod
        mutableParameters["api_key"] = Constants.ApiKey
        mutableParameters["accuracy"] = Methods.Accuracy
        mutableParameters["lat"] = parameters["lat"] as! String
        mutableParameters["lon"] = parameters["lon"] as! String
        mutableParameters["format"] = Methods.Format
        mutableParameters["nojsoncallback"] = Methods.Nojsoncallback
        
        
        let urlString = PhotoClient.Constants.BaseURLSecure + PhotoClient.escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        println(url)
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if let error = downloadError {
//                let newError = PhotoClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: downloadError)
            } else {
                println("Step 3 - taskForResource's completionHandler is invoked.")
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
            println("Step 4 - parseJSONWithCompletionHandler is invoked.")
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
    //Mark: - Error
    
//    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
//        
//        if let parsedResult = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil) as? [String : AnyObject] {
//            if let errorMessage = parsedResult[TheMovieDB.Keys.ErrorStatusMessage] as? String {
//                
//                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
//                
//                return NSError(domain: "TMDB Error", code: 1, userInfo: userInfo)
//            }
//        }
//        
//        return error
//    }
    
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> PhotoClient {
        
        struct Singleton {
            static var sharedInstance = PhotoClient()
        }
        
        return Singleton.sharedInstance
    }
    
    // MARK: - Shared Date Formatter
    
    class var sharedDateFormatter: NSDateFormatter  {
        
        struct Singleton {
            static let dateFormatter = Singleton.generateDateFormatter()
            
            static func generateDateFormatter() -> NSDateFormatter {
                var formatter = NSDateFormatter()
                formatter.dateFormat = "yyyy-mm-dd"
                
                return formatter
            }
        }
        
        return Singleton.dateFormatter
    }
    
    // MARK: - Shared Image Cache
    
    struct Caches {
        static let imageCache = ImageCache()
    }

}