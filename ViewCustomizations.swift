//
//  ViewCustomizations.swift
//  OnMap
//
//  Created by Ashutosh Purushottam on 10/26/15.
//  Copyright © 2015 Vivid Designs. All rights reserved.
//

import UIKit

// MARK: - UIView extensions

extension UIView {
    
    // MARK: -Fade in fade out

    public func fadeIn(duration: NSTimeInterval = 1.0, delay: NSTimeInterval = 0.0, completion: ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.alpha = 1.0
            }, completion: completion)  }
    
    public func fadeOut(duration: NSTimeInterval = 1.0, delay: NSTimeInterval = 0.0, completion: (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.alpha = 0.0
            }, completion: completion)
    }
    

    
}

extension UILabel {

    // MARK: - Animate label

    /* animate label to appear after a delay */
    public func animateLabel(msg: String, desiredDelay: NSTimeInterval, desiredDuration: NSTimeInterval) {
        self.fadeOut(desiredDuration, delay: desiredDelay, completion: {
            (finished: Bool) -> Void in
            self.text = msg
            self.fadeIn()
        })
        
    }
    
    // MARK: -Twinkle
    
    public func twinkleEffectOnLabel() {
        UIView.animateWithDuration(0.8, delay: 0.0, options: [UIViewAnimationOptions.CurveEaseIn, UIViewAnimationOptions.Repeat,
            UIViewAnimationOptions.Autoreverse, UIViewAnimationOptions.AllowUserInteraction], animations: {
                self.alpha = 0.2
            }, completion: nil)
    }

    
    /* stop alpha change of label to stop twinkle */
    public func stopTwinkle(message: String) {
        self.animateLabel(message, desiredDelay: 0.1, desiredDuration: 0.1)
        
    }
    
    // MARK: -Toast like effect on label

    /* Animate a toast like effect on a label 0.5 secs delay is hard-coded as it appears to work nicely */
    
    func animateToastEffectOnLabel(duration: NSTimeInterval, msg: String){
        let initialString  = self.text

        self.fadeIn(duration, delay: 0.0, completion: {
            (finished: Bool) -> Void in
            self.text = msg
        })
        
        self.fadeOut(duration, delay: 0.0, completion: {
            (finished: Bool) -> Void in
            self.text = msg
        })
        
        self.fadeIn(duration, delay: 0.0, completion: {
            (finished: Bool) -> Void in
            self.text = initialString
        })
    }

}



extension UIImage {
    
    static func imageFromColor(color: UIColor, frame: CGRect) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
    color.setFill()
    UIRectFill(frame)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
    }
}


