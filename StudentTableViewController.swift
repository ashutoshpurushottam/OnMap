//
//  StudentTableViewController.swift
//  OnMap
//
//  Created by Ashutosh Purushottam on 10/27/15.
//  Copyright © 2015 Vivid Designs. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class StudentTableViewController: UITableViewController {
    
    // MARK: -Properties 
    var indicator = UIActivityIndicatorView()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.delegate = self

        // Navigation bar items
        let refreshBarButtonItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refreshTapped")
        let pinBarButtonItem: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "Pin"), style: .Plain, target: self, action: "pinTapped")
        let logoutBarButtonItem: UIBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: "logoutTapped")
        navigationItem.rightBarButtonItems = [refreshBarButtonItem, pinBarButtonItem]
        navigationItem.leftBarButtonItem = logoutBarButtonItem
        // indicator
        indicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 40, 40))
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        indicator.center = view.center
        indicator.color = UIColor(red: (248/255.0), green: (54/255.0), blue: (113/255.0), alpha: 1.0)
        view.addSubview(indicator)
        

    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        fetchLocationFromMap()
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        hideIndicator()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let CellReuseID = "StudentCell"
        let locationsParse = ClientParse.sharedInstance.locations
        let studentLocation = locationsParse[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(CellReuseID) as UITableViewCell!
        
        // Set cell defaults
        cell.textLabel!.text = "\(studentLocation.firstName) \(studentLocation.lastName)"
        cell.imageView!.image = UIImage(named: "Pin")
        cell.imageView!.contentMode = UIViewContentMode.ScaleAspectFit

        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return ClientParse.sharedInstance.locations.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let student = ClientParse.sharedInstance.locations[indexPath.row]
        let urlString = student.mediaURL
        let URL = NSURL(string: urlString)
    
        let browser = UIApplication.sharedApplication()
        if let URL = URL
        {
            if browser.canOpenURL(URL)
            {
                browser.openURL(URL)
            } else
            {
                self.showAlertControl(AlertMessages.StudentURLFailure)
            }
        }
        else
        {
            self.showAlertControl(AlertMessages.StudentURLFailure)
        }
    }

    
    // MARK: -Helper functions
    
    func fetchLocationFromMap()
    {
        indicator.startAnimating()
        
        self.fetchStudentInfos() {
            (locations, errorString) in
            
            self.hideIndicator()
            
            if let locations = locations
            {
                ClientParse.sharedInstance.locations = locations
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            }
            else
            {
                dispatch_async(dispatch_get_main_queue()) {
                    self.showAlertControl(AlertMessages.StudentURLFailure)
                }
            }
        }
    }
    
    func hideIndicator()
    {
        dispatch_async(dispatch_get_main_queue()) {
            self.indicator.stopAnimating()
            self.indicator.hidesWhenStopped = true
        }
    }

}


// MARK: -Extension navigation item methods

extension StudentTableViewController {
    
    func refreshTapped()
    {
        fetchLocationFromMap()
    }
    
    func logoutTapped()
    {
        removeFbData()
        dispatch_async(dispatch_get_main_queue()) {
            self.indicator.hidden = false
            self.indicator.startAnimating()
        }
        
        ClientUdacity.sharedInstance.logoutUdacity() {
            (success, errorMessage) in
            
            if errorMessage != nil
            {
                self.showAlertControl(ClientUdacity.UdacityAPIMessages.LogoutError)
                // stop activity indicator
                dispatch_async(dispatch_get_main_queue()) {
                    self.indicator.stopAnimating()
                    self.indicator.hidesWhenStopped = true
                }
            }
            else
            {
                dispatch_async(dispatch_get_main_queue()){
                    let controller = self.storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
                    self.presentViewController(controller, animated: false, completion: nil)
                    
                }
            }
            
        }

    }

    func pinTapped()
    {
        indicator.startAnimating()
        let uniqueKey = ClientUdacity.sharedInstance.userID!
        print("My unique key: \(uniqueKey)")
        
        ClientParse.sharedInstance.getStudentLocations(uniqueKey) {
            (results, errorMessage) in
            
            self.hideIndicator()
            
            if let locations = results
            {

                if locations.count > 0
                {
                    ClientParse.sharedInstance.locations = locations
                    let alert = UIAlertController(title: AlertMessages.AlertTitle,
                        message: AlertMessages.PinExisting, preferredStyle: .Alert)
                    let updateAct = UIAlertAction(title: "Overwrite", style: .Default){
                        (action) in
                        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("EnterLocationNavController") as!UINavigationController
                        self.presentViewController(controller, animated: false, completion: nil)
                    }
                    let cancelAct = UIAlertAction(title: "Cancel", style: .Default) {
                        (action) in
                        alert.dismissViewControllerAnimated(true, completion: nil)
                    }
                    alert.addAction(updateAct)
                    alert.addAction(cancelAct)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    
                }
                else
                {
                    // No locations added for this student
                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("EnterLocationNavController") as! UINavigationController
                    self.presentViewController(controller, animated: false, completion: nil)
                }
            }
            else
            {
                dispatch_async(dispatch_get_main_queue()){
                    self.showAlertControl(AlertMessages.UserLocation)
                }
            }
        }
    }
    
    func removeFbData() {
        //Remove FB Data
        let fbManager = FBSDKLoginManager()
        fbManager.logOut()
        FBSDKAccessToken.setCurrentAccessToken(nil)
    }

    

}