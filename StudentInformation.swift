//
//  StudentInformation.swift
//  OnMap
//
//  Created by Ashutosh Purushottam on 10/30/15.
//  Copyright © 2015 Vivid Designs. All rights reserved.
//

import Foundation

struct StudentInformation {

    // MARK: Properties
    
    var firstName: String = ""
    var lastName: String = ""
    var longitude: Float = 0.0
    var latitude: Float = 0.0
    var mapString: String = ""
    var mediaURL: String = ""
    var objectID: String = ""
    var uniqueKey: String = ""
    
    // MARK: -Initializer
    
    /* StudentInformation Object from a dictionary */
    init(dict: [String: AnyObject])
    {
        
        firstName = dict[ClientParse.JSONResponseKeys.FirstName] as! String
        lastName = dict[ClientParse.JSONResponseKeys.LastName] as! String
        longitude = dict[ClientParse.JSONResponseKeys.Longitude] as! Float
        latitude = dict[ClientParse.JSONResponseKeys.Latitude] as! Float
        mapString = dict[ClientParse.JSONResponseKeys.MapString] as! String
        mediaURL = dict[ClientParse.JSONResponseKeys.MediaURL] as! String
        objectID = dict[ClientParse.JSONResponseKeys.ObjectId] as! String
        uniqueKey = dict[ClientParse.JSONResponseKeys.UniqueKey] as! String
        
    }
    
    // MARK: -Helper
    
    /* Array of StudentInformation Objects from an array of dictionaries */
    static func studentInformationFromResult(results: [[String: AnyObject]]) -> [StudentInformation]
    {
        
        var locations = [StudentInformation]()
        
        for result in results
        {
            let aLocation = StudentInformation(dict: result)
            locations.append(aLocation)
        }
        
        return locations
    }
    
    
}

