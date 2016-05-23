//
//  RippleButton.swift
//  OnMap
//
//  Created by Ashutosh Purushottam on 10/25/15.
//  Copyright © 2015 Vivid Designs. All rights reserved.
//

import UIKit
import QuartzCore

/* Define constants */
let pinkRipple = UIColor(red: (255/255.0), green: (54/255.0), blue: (155/255.0), alpha: 1.0)
let orangeRippleBackground = UIColor(red: (255/255.0), green: (74/255.0), blue: (125/255.0), alpha: 1.0)

@IBDesignable
class RippleButton: UIButton {
    
    
    @IBInspectable var ripplePercent: Float = 0.8 {
        didSet {
            setupRippleView()
        }
    }
    
    // (rgb(191,39,24))
    @IBInspectable var rippleColor: UIColor = pinkRipple {
        didSet {
            rippleView.backgroundColor = rippleColor
        }
    }
    
    @IBInspectable var rippleBackgroundColor: UIColor = orangeRippleBackground {
        didSet {
            rippleBackgroundView.backgroundColor = rippleBackgroundColor
        }
    }
    
    @IBInspectable var buttonCornerRadius: Float = 0 {
        didSet{
            layer.cornerRadius = CGFloat(buttonCornerRadius)
        }
    }
    
    @IBInspectable var rippleOverBounds: Bool = false
    @IBInspectable var shadowRippleRadius: Float = 1
    @IBInspectable var shadowRippleEnable: Bool = true
    @IBInspectable var trackTouchLocation: Bool = false
    @IBInspectable var touchUpAnimationTime: Double = 0.6
    
    let rippleView = UIView()
    let rippleBackgroundView = UIView()
    
    private var tempShadowRadius: CGFloat = 0
    private var tempShadowOpacity: Float = 0
    private var touchCenterLocation: CGPoint?
    
    private var rippleMask: CAShapeLayer? {
        get {
            if !rippleOverBounds {
                let maskLayer = CAShapeLayer()
                maskLayer.path = UIBezierPath(roundedRect: bounds,
                    cornerRadius: layer.cornerRadius).CGPath
                return maskLayer
            } else {
                return nil
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup() {
        setupRippleView()
        
        rippleBackgroundView.backgroundColor = rippleBackgroundColor
        rippleBackgroundView.frame = bounds
        layer.addSublayer(rippleBackgroundView.layer)
        rippleBackgroundView.layer.addSublayer(rippleView.layer)
        rippleBackgroundView.alpha = 0
        
        layer.shadowRadius = 0
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowColor = UIColor(white: 0.0, alpha: 0.5).CGColor
        
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.borderWidth = 1.0
        self.titleLabel?.font = UIFont(name: "Roboto-Regular", size: 18)!
        self.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
    }
    
    private func setupRippleView() {
        let size: CGFloat = CGRectGetWidth(bounds) * CGFloat(ripplePercent)
        let x: CGFloat = (CGRectGetWidth(bounds)/2) - (size/2)
        let y: CGFloat = (CGRectGetHeight(bounds)/2) - (size/2)
        let corner: CGFloat = size/2
        
        rippleView.backgroundColor = rippleColor
        rippleView.frame = CGRectMake(x, y, size, size)
        rippleView.layer.cornerRadius = corner
    }
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        if trackTouchLocation {
            touchCenterLocation = touch.locationInView(self)
        } else {
            touchCenterLocation = nil
        }
        
        UIView.animateWithDuration(0.1,
            animations: {
                self.rippleBackgroundView.alpha = 1
            }, completion: nil)
        
        rippleView.transform = CGAffineTransformMakeScale(0.5, 0.5)
        
        UIView.animateWithDuration(0.7, delay: 0, options: .CurveEaseOut,
            animations: {
                self.rippleView.transform = CGAffineTransformIdentity
            }, completion: nil)
        
        if shadowRippleEnable {
            tempShadowRadius = layer.shadowRadius
            tempShadowOpacity = layer.shadowOpacity
            
            let shadowAnim = CABasicAnimation(keyPath:"shadowRadius")
            shadowAnim.toValue = shadowRippleRadius
            
            let opacityAnim = CABasicAnimation(keyPath:"shadowOpacity")
            opacityAnim.toValue = 1
            
            let groupAnim = CAAnimationGroup()
            groupAnim.duration = 0.7
            groupAnim.fillMode = kCAFillModeForwards
            groupAnim.removedOnCompletion = false
            groupAnim.animations = [shadowAnim, opacityAnim]
            
            layer.addAnimation(groupAnim, forKey:"shadow")
        }
        return super.beginTrackingWithTouch(touch, withEvent: event)
    }
    
    override func cancelTrackingWithEvent(event: UIEvent?) {
        super.cancelTrackingWithEvent(event)
        animateToNormal()
    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        super.endTrackingWithTouch(touch, withEvent: event)
        animateToNormal()
    }
    
    private func animateToNormal() {
        UIView.animateWithDuration(0.1,
            animations: {
                self.rippleBackgroundView.alpha = 1
            },
            completion: {(success: Bool) -> () in
                UIView.animateWithDuration(self.touchUpAnimationTime,
                    animations: {
                        self.rippleBackgroundView.alpha = 0
                    }, completion: nil)
            }
        )
        
        UIView.animateWithDuration(0.7, delay: 0,
            options: [.CurveEaseOut, .BeginFromCurrentState],
            animations: {
                self.rippleView.transform = CGAffineTransformIdentity
                
                let shadowAnim = CABasicAnimation(keyPath:"shadowRadius")
                shadowAnim.toValue = self.tempShadowRadius
                
                let opacityAnim = CABasicAnimation(keyPath:"shadowOpacity")
                opacityAnim.toValue = self.tempShadowOpacity
                
                let groupAnim = CAAnimationGroup()
                groupAnim.duration = 0.7
                groupAnim.fillMode = kCAFillModeForwards
                groupAnim.removedOnCompletion = false
                groupAnim.animations = [shadowAnim, opacityAnim]
                
                self.layer.addAnimation(groupAnim, forKey:"shadowBack")
            }, completion: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupRippleView()
        if let knownTouchCenterLocation = touchCenterLocation {
            rippleView.center = knownTouchCenterLocation
        }
        
        rippleBackgroundView.layer.frame = bounds
        rippleBackgroundView.layer.mask = rippleMask
    }
    
}