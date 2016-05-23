//
//  LoginViewController.swift
//  OnMap
//
//  Created by Ashutosh Purushottam on 10/25/15.
//  Copyright © 2015 Vivid Designs. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    // MARK: -Outlets

    @IBOutlet weak var fbLoginButton: UIButton!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var emailTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomTextField!
    @IBOutlet weak var signUpButton: UIButton!
    // MARK: -Logging
    let TAG = "LoginViewController"
    let SIGNUP_URL = "https://www.udacity.com/account/auth#!/signup"
    var loggedWithFB: Bool = false


    // MARK : properties
    var background: CAGradientLayer? = nil
    var tapRecognizer: UITapGestureRecognizer? = nil
    
    
    // MARK: -Lifecycle methods

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // tap recognition
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
        
        // Setup Initial screen
        configureUI()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        // Add tapRecognizer
        self.addKeyboardDismissRecognizer()
        // Subscribe to keyboard notifications
        self.subscribeToKeyboardNotifications()
        
        // Set user email and password from defaults
        emailTextField.text = NSUserDefaults.standardUserDefaults().valueForKey(UserKeys.UserEmail) as? String ?? ""
        passwordTextField.text = NSUserDefaults.standardUserDefaults().valueForKey(UserKeys.UserPassword) as? String ?? ""
    }
    
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        // Remove tap Recognizer and notification of keyboard
        self.removeKeyboardDismissRecognizer()
        self.unsubscribeToKeyboardNotifications()
        
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
    
    func handleSingleTap(recognizer: UITapGestureRecognizer)
    {
        view.endEditing(true)
    }
    
    // MARK: -Udacity Login Button
    
    
    @IBAction func loginTouchUp(sender: AnyObject)
    {
        
        dismissAnyVisibleKeyboards()
      
        if emailTextField.text?.isEmpty == true || passwordTextField.text?.isEmpty == true
        {
            loginLabel.text = AlertMessages.EmptyEmail
            shakeView(loginLabel)
            
            return
        }
        
        loginLabel.text = LabelMessages.LoggingMessage
        loginLabel.twinkleEffectOnLabel()

    
        let username = emailTextField.text!
        let password = passwordTextField.text!
        
        ClientUdacity.sharedInstance.loginWithCredentials(username, password: password) {
            (success, errorMessage) in
            
            // Change Login label to defualt and stop animation
            dispatch_async(dispatch_get_main_queue()) {
                self.loginLabel.stopTwinkle(LabelMessages.defaultMessage)
                
            }
            
            if success
            {
                self.completeLogin()
            }
            else
            {
                if errorMessage == ClientUdacity.UdacityAPIMessages.NetworkError {
                    self.showAlertControl(AlertMessages.InternetError)
                }
                else if errorMessage == ClientUdacity.UdacityAPIMessages.LoginError {
                    self.showAlertControl(AlertMessages.PasswordError)
                }
                else
                {
                    self.showAlertControl(AlertMessages.GenericError)
                }
            }
        }
    }
    
    
    // MARK: -Login
    
    func completeLogin()
    {
        // Save email and password for udacity for next login
        if !loggedWithFB
        {
            NSUserDefaults.standardUserDefaults().setValue(emailTextField.text!, forKey: UserKeys.UserEmail)
            NSUserDefaults.standardUserDefaults().setValue(passwordTextField.text!, forKey: UserKeys.UserPassword)
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            self.emailTextField.text = ""
            self.passwordTextField.text = ""
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("StudentMapTabController") as! UITabBarController
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    // MARK: -Shake View

    func shakeView(view: UIView)
    {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: CGPointMake(view.center.x - 10, view.center.y))
        animation.toValue = NSValue(CGPoint: CGPointMake(view.center.x + 10, view.center.y))
        loginLabel.layer.addAnimation(animation, forKey: "position")
    }
    
    // MARK: -IBAction Open browser
    
    @IBAction func signUpButtonTouchUp(sender: AnyObject)
    {

        if let requestUrl = NSURL(string: SIGNUP_URL)
        {
            UIApplication.sharedApplication().openURL(requestUrl)
        }
        else
        {
            self.showAlertControl(AlertMessages.SignupError)
        }
    }
    
    
    func textFieldDidBeginEditing(textField: UITextField)
    {
        loginLabel.text = LabelMessages.defaultMessage
    }
    
    
    
    @IBAction func fbLoginTouchUp(sender: AnyObject) {
        fbLoginInitiate()
    }
    
    func fbLoginInitiate() {
        loggedWithFB = true
        let loginManager = FBSDKLoginManager()
        
        loginManager.logInWithReadPermissions(["public_profile", "email"],
            fromViewController: self,
            handler:  {(result:FBSDKLoginManagerLoginResult!, error:NSError!) ->
                Void in
                
                if error != nil {
                    self.removeFbData()
                }
                else if result.isCancelled {
                    // User cancelled 
                    self.removeFbData()
                }
                else
                {
                    if result.grantedPermissions.contains("email") && result.grantedPermissions.contains("public_profile")
                    {
                        self.fetchFacebookProfile()
                    }
                    else
                    {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.showAlertControl(AlertMessages.FacebookLoginError)
                        }

                    }
                }
                
        })
    }
    
    func removeFbData() {
        //Remove FB Data
        let fbManager = FBSDKLoginManager()
        fbManager.logOut()
        FBSDKAccessToken.setCurrentAccessToken(nil)
    }
    
    func fetchFacebookProfile()
    {
        if FBSDKAccessToken.currentAccessToken() != nil {
            let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
            graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                
                if ((error) != nil) {
                    //Handle error
                    dispatch_async(dispatch_get_main_queue()) {
                        self.showAlertControl(AlertMessages.FacebookLoginError)
                    }

                } else {
                    self.completeLogin()

                    let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                    ClientUdacity.sharedInstance.loginWithFBToken(accessToken) {
                        
                        (success, errorMessage) in
                        
                        if success
                        {
                            self.completeLogin()
                        }
                        else
                        {
                            // Show error
                            dispatch_async(dispatch_get_main_queue()) {
                                self.showAlertControl(AlertMessages.FacebookLoginError)
                            }
                        }
                        
                    }
                }
            })
        }
    }
    

}


extension LoginViewController {
    
    // MARK: -Helper functions
    
    func dismissAnyVisibleKeyboards()
    {
        if emailTextField.isFirstResponder() || passwordTextField.isFirstResponder()
        {
            self.view.endEditing(true)
        }
    }
    
    func configureUI()
    {
        
        // MARK: -Background
        background = CAGradientLayer().soundCloudGradient()
        background!.frame = view.bounds
        view.layer.insertSublayer(background!, atIndex: 0)
        
        // MARK: -Labels
        loginLabel.font = UIFont(name: "Roboto-Regular", size: 18)
        loginLabel.textColor = UIColor.whiteColor()
        
        // MARK: -TextFields
        emailTextField.setTextOnTextField("Email")
        passwordTextField.setTextOnTextField("Password")
        passwordTextField.secureTextEntry = true
        
        // MARK: -Signup button
        signUpButton.titleLabel?.font = UIFont(name: "Roboto-Regular", size: 18)!
        signUpButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        signUpButton.setTitle("Dont' have an account? Sign Up", forState: .Normal)
        signUpButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        
        fbLoginButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        fbLoginButton.setFAIcon(FAType.FAFacebook, iconSize: 30, forState: .Normal)

        emailTextField.delegate = self
        passwordTextField.delegate = self

    }
    
}


