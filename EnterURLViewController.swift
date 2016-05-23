//
//  EnterURLViewController.swift
//  OnMap
//
//  Created by Ashutosh Purushottam on 10/28/15.
//  Copyright © 2015 Vivid Designs. All rights reserved.
//

import UIKit
import MapKit

class EnterURLController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {
    
    // MARK: -Outlets
    
    @IBOutlet weak var enterURLTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var checkLinkButton: UIButton!

    // MARK: -Properties
    var searchText: String?
    var longitude: String?
    var latitude: String?

    // MARK: -For map
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    
    let geocoder: CLGeocoder = CLGeocoder()
    
    // MARK: -activity indicator
    var indicator = UIActivityIndicatorView()
    var blurEffectView = UIVisualEffectView()


    // MARK: -LifeCycle methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // tap recognition
        // tap recognition
        enterURLTextField.delegate = self
        mapView.delegate = self
        configureUI()
    }
    
    func configureUI()
    {
        // Cancel BarButtonItem
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancelTapped")
        
        let fieldBackground = CAGradientLayer().midnightGradient()
        fieldBackground.frame = enterURLTextField.bounds
        enterURLTextField.layer.insertSublayer(fieldBackground, atIndex: 0)
        let textFieldattributes = [NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.7),
            NSFontAttributeName: UIFont(name: "Roboto-Regular", size: 20)!]
        enterURLTextField.attributedPlaceholder = NSAttributedString(string: "Enter a link to share here", attributes:textFieldattributes)
        enterURLTextField.font = UIFont(name: "Roboto-Regular", size: 20)
        enterURLTextField.textColor = UIColor.whiteColor()
        enterURLTextField.tintColor = UIColor.whiteColor()
        enterURLTextField.textAlignment = .Center
        
        // Button background opaque
        submitButton.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(1.0)
        // Check Link button
        checkLinkButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        checkLinkButton.setFAIcon(FAType.FAChrome, iconSize: 20, forState: .Normal)
        
        // indicator
        indicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 40, 40))
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        indicator.center = view.center
        indicator.color = UIColor(red: (248/255.0), green: (54/255.0), blue: (113/255.0), alpha: 1.0)
        view.addSubview(indicator)
        // Blur effect
        let blurEffect = UIBlurEffect(style: .Dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.alpha = 0
        view.addSubview(blurEffectView)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        enterURLTextField.resignFirstResponder()
        return true
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        configureMapView()

    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    func cancelTapped()
    {
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    func configureMapView()
    {
        indicator.startAnimating()
        blurEffectView.alpha = 0.5
        
        geocoder.geocodeAddressString(searchText!) {
            (placeMarks, error) in
            
            self.hideIndicator()
            self.blurEffectView.alpha = 0
            
            if error == nil
            {
                if let placeMarks = placeMarks
                {
                    let placeMark = placeMarks[0]
                    let coordinates = placeMark.location!.coordinate
                    self.pointAnnotation = MKPointAnnotation()
                    self.pointAnnotation.title = self.searchText
                    self.pointAnnotation.coordinate = coordinates
                    let latitudeString = String(coordinates.latitude)
                    self.latitude = latitudeString
                    let longitudeString = String(coordinates.longitude)
                    self.longitude = longitudeString
                    self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
                    self.mapView.centerCoordinate = self.pointAnnotation.coordinate
                    self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
                    
                }
            }
            
            else // error case
            {
                self.showAlertControlToDissmiss(AlertMessages.PlaceNotFound)
                return
            }
            
            
        }
        
    }
    
    // MARK : - Submit location and URL
    
    @IBAction func submitBtnTapped(sender: AnyObject)
    {
        
        let userID = ClientUdacity.sharedInstance.userID!
        let firstName = ClientUdacity.sharedInstance.name?.firstName
        let lastName = ClientUdacity.sharedInstance.name?.lastName
        let mapString = searchText!
        let mediaURL = enterURLTextField.text
        let longitude = Float(self.longitude!)
        let latitude = Float(self.latitude!)


        if enterURLTextField.text?.isEmpty == true
        {
            self.showAlertControl(AlertMessages.EmptyUrlField)
            return
        }
        let locationData: [String: AnyObject] = [
            ClientParse.JSONResponseKeys.UniqueKey: userID,
            ClientParse.JSONResponseKeys.FirstName: firstName!,
            ClientParse.JSONResponseKeys.LastName: lastName!,
            ClientParse.JSONResponseKeys.MapString: mapString,
            ClientParse.JSONResponseKeys.MediaURL: mediaURL!,
            ClientParse.JSONResponseKeys.Longitude: longitude!,
            ClientParse.JSONResponseKeys.Latitude: latitude!
        ]
        
        let locations = ClientParse.sharedInstance.locations
        if locations.count == 0
        {
            ClientParse.sharedInstance.postStudentLocation(locationData) {
                (success, error) in
                
                if success
                {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.showAlertControl(AlertMessages.PostSuccess)
                        let longDouble = Double(self.longitude!)
                        let latDouble = Double(self.latitude!)
                        NSUserDefaults.standardUserDefaults().setDouble(longDouble!, forKey: "Longitude")
                        NSUserDefaults.standardUserDefaults().setDouble(latDouble!, forKey: "Latitude")
                        
                    }
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.showAlertControl(AlertMessages.PostFailure)
                    }
                }
                
            }

        }
        else
        {

            ClientParse.sharedInstance.putStudentLocation(locationData) {
                (success, errorMessage) in
                
                if success
                {
                    dispatch_async(dispatch_get_main_queue()){
                        self.enterURLTextField.text = ""
                        let longDouble = Double(self.longitude!)
                        let latDouble = Double(self.latitude!)

                        NSUserDefaults.standardUserDefaults().setDouble(longDouble!, forKey: UserKeys.UserLongitude)
                        NSUserDefaults.standardUserDefaults().setDouble(latDouble!, forKey: UserKeys.UserLatitude)
                        let tabController = self.storyboard!.instantiateViewControllerWithIdentifier("StudentMapTabController") as! UITabBarController
                        self.presentViewController(tabController, animated: true, completion: nil)
                    }
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue()){
                        self.showAlertControl(AlertMessages.UpdateFailure)
                    }
                }
            }
        }
    }
    
    // MARK: -Check URL entered by user
    
    @IBAction func checkURLTapped(sender: AnyObject)
    {
        if enterURLTextField.text?.isEmpty == true
        {
            showAlertControl(AlertMessages.EmptyUrlButton)
            return
        }
        let browser = UIApplication.sharedApplication()
        let urlString = enterURLTextField.text!
        let URL = NSURL(string: urlString)
        if let URL = URL
        {
            if browser.canOpenURL(URL)
            {
                browser.openURL(URL)
            }
            else
            {
                self.showAlertControl(AlertMessages.URLCantOpen)
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
    
    // MARK: -Show alert control with dissmiss functionality
    
    func showAlertControlToDissmiss(msg: String)
    {
        
        let alertController = UIAlertController(title: AlertMessages.AlertTitle, message: msg, preferredStyle: .Alert)
        let cancelAct = UIAlertAction(title: "OK", style: .Default) {
            (action) in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        alertController.addAction(cancelAct)
        presentViewController(alertController, animated: true, completion: nil)
        
    }




}
