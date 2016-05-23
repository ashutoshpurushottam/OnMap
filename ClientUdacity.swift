//
//  ClientUdacity.swift
//  OnMap
//
//  Created by Ashutosh Purushottam on 11/1/15.
//  Copyright © 2015 Vivid Designs. All rights reserved.

/* Helper class to deal with Udacity API hits */

import Foundation

class ClientUdacity: NSObject {
    
    // MARK: -Singleton
    static let sharedInstance = ClientUdacity()
    
    // MARK: -Properties
    var userID: String?
    var name: Name?
    var fbToken: String?
    
    struct Name {
        var firstName = ""
        var lastName = ""
        // Computed property: full name
        var fullName : String {
            return "\(firstName) \(lastName)"
        }
    }
    
        
    // MARK: -Methods

    /* Create a request from Method name for Udacity API */
    func requestForMethod(method: String) -> NSMutableURLRequest
    {
        let urlString = URL.BaseURL + method
        let url = NSURL(string: urlString)!
        return NSMutableURLRequest(URL: url)
    }
    
    /* Create NSURLTask  */
    func taskWithRequest(request: NSURLRequest,
        completionHandler: (results: AnyObject?, error: NSError?) -> Void) -> NSURLSessionTask
    {
            
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request) {
                (data, response, error) in
                
                if error == nil {
                    let dataTrimmed = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
                    UtilityClient.parseJSONWithCompletionHandler(dataTrimmed, completionHandler: completionHandler)
                }
                else
                {
                    completionHandler(results: nil, error: error)
                }
                
            }
            task.resume()
            return task
    }
    
    /* Login to the Udacity with username and password */
    func loginWithCredentials(username: String,
        password: String,
        completionHandler: (success: Bool, errorMessage: String?) -> Void )
    {
        
            let request = requestForMethod(Methods.Session)
            request.HTTPMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
            
            // Call task to hit API and fetch result 
            taskWithRequest(request) {
                (result, error) in
                
                if error != nil
                {
                    completionHandler(success: false, errorMessage: UdacityAPIMessages.NetworkError)
                }
                // We got some response
                else
                {
                    if let account = result!.valueForKey(JSONResponseKeys.Account) as? NSDictionary
                    {
                        // Get userID to fetch all information about the student
                        if let userID = account.valueForKey(JSONResponseKeys.Key) as? String
                        {
                            // Get user info here
                            self.userID = userID
                            self.getUserInfo(self.userID!) {
                                (success, errorMessage) in
                                
                                if success
                                {
                                    print("My name: \(self.name!.fullName)")
                                    completionHandler(success: true, errorMessage: nil)
                                }
                                else
                                {
                                    print("Failed to fetch name from Udacity")
                                    completionHandler(success: false, errorMessage: UdacityAPIMessages.LoginError)
                                }
                            }
                            
                        }
                        else
                        {
                            print("Failed to get userID from the response")
                            completionHandler(success: false, errorMessage: UdacityAPIMessages.LoginError)
                        }
                        
                        
                    }
                    else
                    {
                        completionHandler(success: false, errorMessage: UdacityAPIMessages.LoginError)
                    }
                    
                }
                
            }
            
    } // End of login With Credentials
    
    func loginWithFBToken(token: String, completionHandler: (success: Bool, errorMessage: String?) -> Void ){
        
        self.fbToken = token
        let request = requestForMethod(Methods.Session)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.HTTPBody = "{\"facebook_mobile\": {\"access_token\":\"\(token)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        taskWithRequest(request) {
            (result, error) in
            
            if error == nil
            {
                if let account = result!.valueForKey(JSONResponseKeys.Account) as? NSDictionary
                {
                    if let userID = account.valueForKey(JSONResponseKeys.Key) as? String
                    {
                        self.userID = userID
                        self.getUserInfo(self.userID!) {
                            (success, errorMessage) in
                            
                            if success
                            {
                                print("My name: \(self.name!.fullName)")
                                completionHandler(success: true, errorMessage: nil)
                            }
                            else
                            {
                                print("Failed to fetch name from Udacity")
                                completionHandler(success: false, errorMessage: UdacityAPIMessages.LoginError)
                            }
                        }
                        
                    }
                }

                else
                {
                    completionHandler(success: false, errorMessage: UdacityAPIMessages.LoginError)
                }
            }
            else
            {
                completionHandler(success: false, errorMessage: error?.localizedDescription)
            }
            
        }
        
    }
    

    /* Logout from udacity */
    func logoutUdacity(completionHandler: (success: Bool, errorMessage: String?) -> Void)
    {
        
        let request = requestForMethod(Methods.Session)
        request.HTTPMethod = "DELETE"

        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies!  {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie
        {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        taskWithRequest(request) {
            (result, error ) in
            
            if error == nil
            {
                completionHandler(success: true, errorMessage: nil)
            }
            else
            {
                completionHandler(success: false, errorMessage: UdacityAPIMessages.LogoutError)
            }
        }
    } // end of logoutUdacity
    
    
    /* Get user info from udacity client */
    func getUserInfo(userID: String, completionHandler: (success: Bool, errorMessage: String?) -> Void)
    {
        let request = requestForMethod(Methods.Users + userID)
        print("Request: \(request)")
        request.HTTPMethod = "GET"
        
        taskWithRequest(request) {
            (result, error) in
            
            if error == nil
            {
                if let user = result!.valueForKey(JSONResponseKeys.User) as? NSDictionary
                {
                    self.name = Name()
                    if let lastName = user.valueForKey(JSONResponseKeys.lastName) as? String
                    {
                      self.name?.lastName = lastName
                    } else {completionHandler(success: false, errorMessage: UdacityAPIMessages.LoginError)}
                    
                    if let firstName = user.valueForKey(JSONResponseKeys.firstName) as? String
                    {
                      self.name?.firstName = firstName
                    } else {completionHandler(success: false, errorMessage: UdacityAPIMessages.LoginError)}
                    
                    completionHandler(success: true, errorMessage: nil)
                    
                }
                else
                {
                    completionHandler(success: false, errorMessage: UdacityAPIMessages.LoginError)
                }
                
            }
            else
            {
               completionHandler(success:false, errorMessage: UdacityAPIMessages.LoginError)
            }
            
        } // End of taskWithRequest
        
    } // End of get user info
}


extension ClientUdacity {
    
    struct URL {
        static let BaseURL : String = "https://www.udacity.com/api/"
    }
    
    struct Methods {
        static let Session = "session"
        static let Users = "users/"
    }
    
    struct UdacityAPIMessages {
        
        static let LoginError = "Login failed due to incorrect username or password"
        static let LogoutError = "Error logging out of Udacity"
        static let NetworkError = "Network problem connecting to Udacity."
    }
    
    struct JSONResponseKeys {
        static let Account = "account"
        static let Key = "key"
        static let User = "user"
        static let lastName = "last_name"
        static let firstName = "first_name"
    }
    
}