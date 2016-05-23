//
//  CAGGradientLayerExtension.swift
//  OnMap
//
//  Created by Ashutosh Purushottam on 10/25/15.
//  Copyright © 2015 Vivid Designs. All rights reserved.
//

import UIKit

extension CAGradientLayer {
    
    // MARK: -Gradient patterns
    
    public func bourbonGradient() -> CAGradientLayer {
        
        let topColor = UIColor(red: (236/255.0), green: (111/255.0), blue: (102/255.0), alpha: 1)
        let bottomColor = UIColor(red: (243/255.0), green: (161/255.0), blue: (131/255.0), alpha: 1)
        
        let gradientColors: [CGColor] = [topColor.CGColor, bottomColor.CGColor]
        let gradientLocations: [Float] = [0.0,1.0]
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations
        
        return gradientLayer
        
    }
    
    public func strainGradient() -> CAGradientLayer {
        let topColor = UIColor(red: (135/255.0), green: (0/255.0), blue: (0/255.0), alpha: 1)
        let bottomColor = UIColor(red: (25/255.0), green: (10/255.0), blue: (5/255.0), alpha: 1)
        
        let gradientColors: [CGColor] = [topColor.CGColor, bottomColor.CGColor]
        let gradientLocations: [Float] = [0.0,1.0]
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations
        
        return gradientLayer
        
    }
    
    public func namnGradient() -> CAGradientLayer {
        let topColor = UIColor(red: (167/255.0), green: (55/255.0), blue: (55/255.0), alpha: 1)
        let bottomColor = UIColor(red: (122/255.0), green: (40/255.0), blue: (40/255.0), alpha: 1)
        
        let gradientColors: [CGColor] = [topColor.CGColor, bottomColor.CGColor]
        let gradientLocations: [Float] = [0.0,1.0]
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations
        
        return gradientLayer
        
    }
    
    public func torqouiseFlowGradient() -> CAGradientLayer {
        
        let topColor = UIColor(red: (19/255.0), green: (106/255.0), blue: (138/255.0), alpha: 1.0)
        let bottomColor = UIColor(red: (38/255.0), green: (120/255.0), blue: (113/255.0), alpha: 1.0)
        
        let gradientColors: [CGColor] = [topColor.CGColor, bottomColor.CGColor]
        let gradientLocations: [Float] = [0.0,1.0]
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations
        
        return gradientLayer
        
    }
    
    public func soundCloudGradient() -> CAGradientLayer {
        
        let topColor = UIColor(red: (254/255.0), green: (140/255.0), blue: (0/255.0), alpha: 1.0)
        let bottomColor = UIColor(red: (248/255.0), green: (54/255.0), blue: (113/255.0), alpha: 1.0)
        
        let gradientColors: [CGColor] = [topColor.CGColor, bottomColor.CGColor]
        let gradientLocations: [Float] = [0.0,1.0]
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations
        
        return gradientLayer
        
    }
    
    public func sunRiseGradient() -> CAGradientLayer {
        
        let topColor = UIColor(red: (255/255.0), green: (81/255.0), blue: (47/255.0), alpha: 1.0)
        let bottomColor = UIColor(red: (240/255.0), green: (152/255.0), blue: (25/255.0), alpha: 1.0)
        
        let gradientColors: [CGColor] = [topColor.CGColor, bottomColor.CGColor]
        let gradientLocations: [Float] = [0.0,1.0]
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations
        
        return gradientLayer
        
    }
    
    public func steelGrayGradient() -> CAGradientLayer {
        
        let topColor = UIColor(red: (31/255.0), green: (28/255.0), blue: (44/255.0), alpha: 1.0)
        let bottomColor = UIColor(red: (146/255.0), green: (141/255.0), blue: (171/255.0), alpha: 1.0)
        
        let gradientColors: [CGColor] = [topColor.CGColor, bottomColor.CGColor]
        let gradientLocations: [Float] = [0.0,1.0]
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations
        
        return gradientLayer
    }
    
    public func midnightGradient() -> CAGradientLayer {
        
        let topColor = UIColor(red: (35/255.0), green: (37/255.0), blue: (38/255.0), alpha: 1.0)
        let bottomColor = UIColor(red: (65/255.0), green: (67/255.0), blue: (69/255.0), alpha: 1.0)
        
        let gradientColors: [CGColor] = [topColor.CGColor, bottomColor.CGColor]
        let gradientLocations: [Float] = [0.0,1.0]
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations
        
        return gradientLayer
        
    }

}
