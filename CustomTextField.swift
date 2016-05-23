//
//  CustomTextField.swift
//  OnMap
//
//  Created by Ashutosh Purushottam on 10/25/15.
//  Copyright © 2015 Vivid Designs. All rights reserved.
//

import Foundation
import UIKit


// MARK: -CustomTextField

public class CustomTextField: UITextField {
    
    // Extension can not contain stored properties
    let textFieldattributes = [NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.7),
        NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 14)!]
    
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.layer.cornerRadius = 5.0;
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.borderWidth = 1.0
        self.backgroundColor = UIColor.clearColor()
        self.textColor = UIColor.whiteColor()
        self.tintColor = UIColor.whiteColor()
        
    }
    
}

extension CustomTextField {
    
    // MARK: - Set placeholder text
    
    func setTextOnTextField(msg: String){
        
        self.attributedPlaceholder = NSAttributedString(string:msg,
            attributes:textFieldattributes)
        
    }
    
}


