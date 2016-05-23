//
//  ClientParse.swift
//  OnMap
//
//  Created by Ashutosh Purushottam on 11/1/15.
//  Copyright © 2015 Vivid Designs. All rights reserved.
//

import Foundation

class ClientParse: NSObject {
    
    static let sharedInstance = ClientParse()
    var locations : [StudentInformation] // represent unique student
    var objectID: String?
    
    override init()
    {
        locations = [StudentInformation]()
        super.init()
    }
    
    /* Create a request from Method name for Udacity API */
    func requestForMethod(method: String) -> NSMutableURLRequest
    {
        let urlString = URL.BaseURL + method
        let url = NSURL(string: urlString)!
        return NSMutableURLRequest(URL: url)
    }
    
    func taskWithRequest( request: NSMutableURLRequest, completionHandler: (results: AnyObject?, error: NSError?) -> Void ) -> NSURLSessionTask
    {
        
        request.addValue(ParseAPI.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ParseAPI.APIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest( request ) {
            (data, response, error) in
            if error == nil
            {
                UtilityClient.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
                
            }
            else
            {
                completionHandler(results: nil, error: error)
            }
        }
        
        task.resume()
        return task
    }
    
    /* Get student locations */
    func getStudentsInfo( completionHandler: (success: Bool, errorMessage: String?) -> Void )
    {
        
        let urlString = URL.BaseURL + "?order=-updatedAt"
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        taskWithRequest(request) {
            (JSONResult, error) in
            
            // no error 
            if error == nil
            {
                if let results = JSONResult?.valueForKey(JSONResponseKeys.Results)  as? [[String : AnyObject]] {
                    self.locations = StudentInformation.studentInformationFromResult(results)
                    completionHandler(success: true, errorMessage: nil)
                    
                }
            }
            else
            {
                completionHandler(success: false, errorMessage: ParseMessages.ErrorDownload)
            }
            
        }
    }
    
    
    func getStudentLocations(uniqueKey: String, completionHandler: (results: [StudentInformation]?, errorMessage: String?) -> Void )
    {
        let urlString = "\(URL.BaseURL)?where=%7B%22uniqueKey%22%3A%22\(uniqueKey)%22%7D"
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        taskWithRequest(request) {
            (JSONResult, error) in
            
            if error == nil
            {
                if let results = JSONResult?.valueForKey(JSONResponseKeys.Results) as? [[String : AnyObject]] {
                    var locations = StudentInformation.studentInformationFromResult(results)
                    let location = locations[0]
                    self.objectID = location.objectID
                    
                    completionHandler(results: locations, errorMessage: nil)
                }
                else
                {
                    completionHandler(results: nil, errorMessage: ParseMessages.ErrorDownload)
                }
            }
            else
            {
                completionHandler(results: nil, errorMessage: ParseMessages.ErrorDownload)
            }
        }
    
    }
    
    func postStudentLocation(data: [String : AnyObject], completionHandler: (success: Bool, errorMessage: String?) -> Void)
    {
        
        
        let urlString = URL.BaseURL
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("keep-alive", forHTTPHeaderField: "Connection")
        
        do
        {
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(data, options: .PrettyPrinted)
        }
        
        taskWithRequest(request) {
            (JSONResult, error) in
            
            if error == nil {
                completionHandler(success: true, errorMessage: nil)
            }
            else
            {
                completionHandler(success: false, errorMessage: ParseMessages.ErrorPostingLocation)
            }
            
        }
    }
    
    func putStudentLocation(data: [String: AnyObject], completionHandler: (success: Bool, errorMessage: String?) -> Void)
    {
        let urlString = URL.BaseURL + "/\(self.objectID!)"
        
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "PUT"

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("keep-alive", forHTTPHeaderField: "Connection")
        
        do
        {
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(data, options: .PrettyPrinted)
        }
        taskWithRequest(request) {
            (JSONResult, error ) in
            
            if error == nil
            {
                completionHandler(success: true, errorMessage: nil)
            }
            else
            {
                print(error)
                completionHandler(success: false, errorMessage: ParseMessages.ErrorPostingLocation)
            }
            
        }
        
        
    }
    
 
} // end of class ClientParse


// MARK: Extension

extension ClientParse {
    
    struct URL {
        static let BaseURL: String = "https://api.parse.com/1/classes/StudentLocation"
    }
    
    struct ParseAPI {
        static let AppID: String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let APIKey: String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    }
    
    struct JSONResponseKeys {
        static let Results: String = "results"
        static let Error: String = "error"
        
        static let ObjectId: String = "objectId"
        static let UniqueKey: String = "uniqueKey"
        static let FirstName: String = "firstName"
        static let LastName: String = "lastName"
        static let MapString: String = "mapString"
        static let MediaURL: String = "mediaURL"
        static let Latitude: String = "latitude"
        static let Longitude: String = "longitude"
        
        //for posting
        static let createdAt: String = "createdAt"
        
        //for getting
        static let updatedAt: String = "updatedAt"
    }
    
    struct ParseMessages {
        
        static let ErrorDownload = "Failed to fetch student information from parse API"
        static let ErrorPostingLocation = "Could not post location fot the user"
    }
    
}