//
//  ViewControllerExtension.swift
//  OnMap
//
//  Created by Ashutosh Purushottam on 11/5/15.
//  Copyright © 2015 Vivid Designs. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showAlertControl(msg: String)
    {
        
        let alertController = UIAlertController(title: AlertMessages.AlertTitle, message: msg, preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: AlertMessages.ButtonText, style: .Default, handler: nil)
        
        alertController.addAction(defaultAction)
        presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    /* Declared at one place so as to be accessible to all view controllers */
    func fetchStudentInfos(completionHandler: (results:[StudentInformation]? , errorString: String?) -> Void)
    {
        
        ClientParse.sharedInstance.getStudentsInfo() {
            (success, errorMessage) in
            
            if success
            {
                print("Successfully fetched locations fetchStudentInfos")
                let studentInfo = ClientParse.sharedInstance.locations
                completionHandler(results: studentInfo, errorString: nil)
            }
            else
            {
                print("Failed to fetch locations in fetchStudentInfos")
                completionHandler(results: nil, errorString: errorMessage)
            }
        }
    }
    
    
    // MARK: -Error messages to show on label
    
    struct AlertMessages
    {
        
        static let AlertTitle = "On The Map"
        static let ButtonText = "OK"
        static let InternetError = "Please check your internet connection and try to login again."
        static let PasswordError = "The email or password entered appears to be incorrect."
        static let GenericError = "Invalid response from the server. Please try to login after some time"
        static let EmptyEmail = "Email/Password fields can not be empty"
        static let StudentDownloadFailure = "Could not download student information over the network."
        static let StudentURLFailure = "The URL provided by the student can not be opened by Safari."
        static let LogoutFailed = "Failed to logout from the udacity"
        static let LocationEmpty = "Enter some location before submitting"
        static let SignupError = "Could not open signp page. Please check your internet and try again."
        static let PlaceNotFound = "The place you entered could not be resolved in the map. Please check your entry and try again."
        static let PinExisting = "You already have a pin on the map. Do you want to update it?"
        static let UserLocation = "Could not fetch your already entered locations"
        static let PostSuccess = "Location and URL successfully posted"
        static let PostFailure = "Failed to post location and URL"
        static let UpdateSuccess = "Location and URL successfully updated"
        static let UpdateFailure = "Failed to update location and URL"
        static let EmptyUrlField = "The url field should not be empty"
        static let EmptyUrlButton = "Enter some URL before checking it on browser"
        static let URLCantOpen = "This URL can not be opened by the browser"
        static let FacebookLoginError = "Failed to login with Facebook credentials"
        
    }
    
    // MARK: -Keys for Udacity and FB
    struct UserKeys
    {
        static let UserEmail = "userEmail"
        static let UserPassword = "userPassword"
        static let UserLongitude = "Longitude"
        static let UserLatitude = "Latitude"
        static let AccessToken = "access_token"
    }
    
    struct LabelMessages {
        
        static let defaultMessage = "Login to Udacity"
        static let LoggingMessage = "Logging..."
        
    }
    
    // MARK: -Error Descriptions
    
    struct ErrorDescriptions {
        
        static let InternetError = "The Internet connection appears to be offline."
        static let UserNamePasswordError = "Could not get valid response from server"
    }
    
    
    
    
}

