//
//  StudentMapViewController.swift
//  OnMap
//
//  Created by Ashutosh Purushottam on 10/27/15.
//  Copyright © 2015 Vivid Designs. All rights reserved.
//

import UIKit
import MapKit
import FBSDKCoreKit
import FBSDKLoginKit


class StudentMapViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: -Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // MARK :- Properties
    let TAG = "StudentMapViewController: "
    
    // MARK: Lifecycle methods 
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        mapView.delegate = self
        
        // Navigation bar
        let refreshBarButtonItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refreshTapped")
        let pinBarButtonItem: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "Pin"), style: .Plain, target: self, action: "pinTapped")
        let logoutBarButtonItem: UIBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: "logoutTapped")
        navigationItem.rightBarButtonItems = [refreshBarButtonItem, pinBarButtonItem]
        navigationItem.leftBarButtonItem = logoutBarButtonItem
        activityIndicator.hidden = true
        activityIndicator.color = UIColor(red: (248/255.0), green: (54/255.0), blue: (113/255.0), alpha: 1.0)
        
   }

    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        fetchLocationsForMap()
        configureMap()
        
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        activityIndicator.stopAnimating()
        activityIndicator.hidesWhenStopped = true
    }
    
    // MARK: -Configuere map to point to user entered location
    
    func configureMap()
    {
        let mapLong: Double = NSUserDefaults.standardUserDefaults().valueForKey(UserKeys.UserLongitude) as? Double ?? 0
        let mapLat: Double = NSUserDefaults.standardUserDefaults().valueForKey(UserKeys.UserLatitude) as? Double ?? 0
        
        if (mapLong != 0 && mapLat != 0)
        {
            let mapCenter = CLLocationCoordinate2D(latitude: mapLat, longitude: mapLong)
            let region = MKCoordinateRegionMake(mapCenter, MKCoordinateSpanMake(20, 20))
            mapView.setRegion(region, animated: true)
        }
        
    }

    // MARK: - MapView methods

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?
    {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil
        {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else
        {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    /* call on selection of pin */

    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
    {
        
        if control == view.rightCalloutAccessoryView
        {
            
            let browser = UIApplication.sharedApplication()
            let urlString = view.annotation?.subtitle
            let finalString: String = urlString!! ?? ""
            let URL = NSURL(string: finalString)
            if let URL = URL
            {
                if browser.canOpenURL(URL)
                {
                    browser.openURL(URL)
                }
                else
                {
                    self.showAlertControl(AlertMessages.StudentURLFailure)
                }
            }
            else
            {
                self.showAlertControl(AlertMessages.StudentURLFailure)
            }
        }
    }
    
    
    
    // MARK: -Student pins and infos
    
    func fetchLocationsForMap()
    {
        
        self.activityIndicator.hidden = false
        self.activityIndicator.startAnimating()
        
        self.fetchStudentInfos() {
            (results, errorString) in
            
            dispatch_async(dispatch_get_main_queue()) {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidesWhenStopped = true
            }

            if errorString != nil
            {
                
                self.showAlertControl(AlertMessages.StudentDownloadFailure)
            }
            else
            {
                var annotations = [MKPointAnnotation]()
                for studentLocation in results!
                {
                    
                    let lat = CLLocationDegrees(studentLocation.latitude)
                    let long = CLLocationDegrees(studentLocation.longitude)
                    
                    // The lat and long are used to create a CLLocationCoordinates2D instance.
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    
                    let first = studentLocation.firstName
                    let last = studentLocation.lastName
                    let mediaURL = studentLocation.mediaURL
                    
                    // Here we create the annotation and set its coordiate, title, and subtitle properties
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = "\(first) \(last)"
                    annotation.subtitle = mediaURL
                    
                    // Finally we place the annotation in an array of annotations.
                    annotations.append(annotation)
                    
                }
                self.mapView.addAnnotations(annotations)
            }
            
        }
    }
    
    
}

// MARK: - extension for taking away navigation bar tap methods

extension StudentMapViewController {
    
    func refreshTapped()
    {
        fetchLocationsForMap()
    }
    
    func logoutTapped()
    {
        removeFbData()
        dispatch_async(dispatch_get_main_queue()) {
            self.activityIndicator.hidden = false
            self.activityIndicator.startAnimating()
        }
        
        ClientUdacity.sharedInstance.logoutUdacity() {
            (success, errorMessage) in
            
            if errorMessage != nil
            {
                self.showAlertControl(ClientUdacity.UdacityAPIMessages.LogoutError)
                // stop activity indicator
                dispatch_async(dispatch_get_main_queue()) {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.hidesWhenStopped = true
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
        activityIndicator.startAnimating()
        let uniqueKey = ClientUdacity.sharedInstance.userID!
        print(self.TAG + "My unique key: \(uniqueKey)")
        
        ClientParse.sharedInstance.getStudentLocations(uniqueKey) {
            (results, errorMessage) in
            
            dispatch_async(dispatch_get_main_queue()) {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidesWhenStopped = true
            }
            
            if let locations = results
            {
                print("User locations so far: \(locations)")
                
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
                self.showAlertControl(AlertMessages.UserLocation)
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




