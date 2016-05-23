//
//  EnterLocationViewController.swift
//  OnMap
//
//  Created by Ashutosh Purushottam on 10/28/15.
//  Copyright © 2015 Vivid Designs. All rights reserved.
//

import UIKit

class EnterLocationController: UIViewController, UITextFieldDelegate {

    // MARK: -Outlets

    @IBOutlet weak var searchLocationButton: RippleButton!
    @IBOutlet weak var enterLocationTextField: UITextField!
    @IBOutlet weak var topMessageLabel: UILabel!
    @IBOutlet weak var bottomMessageLabel: UILabel!
    @IBOutlet weak var centerMessageLabel: UILabel!
    
    // MARK: -Properties
    var background: CAGradientLayer? = nil
    var tapRecognizer: UITapGestureRecognizer? = nil

    
    // MARK: -Lifecycle Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // tap recognition
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleDoubleTap:")
        tapRecognizer?.numberOfTapsRequired = 2
        
        enterLocationTextField.delegate = self

        configureUI()
        // Navigation Bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancelTapped")
        
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        // Add tapRecognizer
        addKeyboardDismissRecognizer()
        // Subscribe to keyboard notifications
        subscribeToKeyboardNotifications()

    }
    
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillAppear(animated)
        // Remove tap Recognizer and notification of keyboard
        removeKeyboardDismissRecognizer()
        unsubscribeToKeyboardNotifications()

    }
    
    // MARK: - TextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        enterLocationTextField.resignFirstResponder()
        return true
    }
    
    //MARK: -UI Config
    
    func configureUI()
    {
        
        background = CAGradientLayer().midnightGradient()
        background!.frame = view.bounds
        view.layer.insertSublayer(background!, atIndex: 0)
        
        // layer on TextField
        let fieldBackground = CAGradientLayer().steelGrayGradient()
        fieldBackground.frame = enterLocationTextField.bounds
        enterLocationTextField.layer.insertSublayer(fieldBackground, atIndex: 0)
        
        
        // Labels
        topMessageLabel.font = UIFont(name: "Roboto-Regular", size: 24)
        topMessageLabel.textColor = UIColor.whiteColor()
        topMessageLabel.textAlignment = .Center
        
        centerMessageLabel.font = UIFont(name: "Roboto-Regular", size: 24)
        centerMessageLabel.textColor = UIColor.whiteColor()
        centerMessageLabel.textAlignment = .Center
        
        bottomMessageLabel.font = UIFont(name: "Roboto-Regular", size: 24)
        bottomMessageLabel.textColor = UIColor.whiteColor()
        bottomMessageLabel.textAlignment = .Center
        
        // TextField
        let textFieldattributes = [NSForegroundColorAttributeName: UIColor(white: 1, alpha: 1.0),
            NSFontAttributeName: UIFont(name: "Roboto-Regular", size: 24)!]
        enterLocationTextField.attributedPlaceholder = NSAttributedString(string: "Enter you location here", attributes:textFieldattributes)
        enterLocationTextField.font = UIFont(name: "Roboto-Regular", size: 24)
        enterLocationTextField.textColor = UIColor.whiteColor()
        enterLocationTextField.tintColor = UIColor.whiteColor()
        
    }
    
    
    // MARK: - handle tap and keyboard appearance/disappearance
    
    func addKeyboardDismissRecognizer()
    {
        view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer()
    {
        view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func subscribeToKeyboardNotifications()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications()
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification)
    {
        // push the frame up to unhide textfield
        view.bounds.origin.y = getKeyboardHeight(notification)/2
        background!.frame = view.bounds
    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        
        // reset the bounds when keyboard disappears
        view.bounds.origin.y = 0
        background!.frame = view.bounds
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat
    {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    func handleDoubleTap(recognizer: UITapGestureRecognizer)
    {
        view.endEditing(true)
    }
    

    
    
    // MARK: - Navigation Item actions

    func cancelTapped()
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func searchLocationTapped(sender: AnyObject)
    {
        
        if enterLocationTextField.text?.isEmpty == true
        {
            showAlertControl(AlertMessages.LocationEmpty)
            return
        }
        
        let navController = storyboard?.instantiateViewControllerWithIdentifier("EnterURLNavController") as! UINavigationController
        let enterURLController = navController.viewControllers[0] as! EnterURLController
        enterURLController.searchText = enterLocationTextField.text
        // Reset text editor field
        enterLocationTextField.text = ""
        presentViewController(navController, animated: false, completion: nil)
        
    }
    
    
}


