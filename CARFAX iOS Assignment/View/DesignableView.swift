//
//  DesignableView.swift
//  CARFAX iOS Assignment
//
//  Created by Andres S. Hernandez G. on 8/19/19.
//  Copyright © 2019 Andres S. Hernandez G. All rights reserved.
//

import UIKit

// MARK: - Designable class to assign in Storyboard
@IBDesignable class DesignableView: UIView
{
    @IBInspectable var gradientColor1: UIColor = UIColor.white {
        didSet{
            self.setGradient()
        }
    }
    
    @IBInspectable var gradientColor2: UIColor = UIColor.white {
        didSet{
            self.setGradient()
        }
    }
    
    @IBInspectable var gradientStartPoint: CGPoint = .zero {
        didSet{
            self.setGradient()
        }
    }
    
    @IBInspectable var gradientEndPoint: CGPoint = CGPoint(x: 0, y: 1) {
        didSet{
            self.setGradient()
        }
    }
    
    // MARK: - Function that sets a gradient color change as background using CAGradientLayers
    private func setGradient()
    {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [self.gradientColor1.cgColor, self.gradientColor2.cgColor]
        gradientLayer.startPoint = self.gradientStartPoint
        gradientLayer.endPoint = self.gradientEndPoint
        gradientLayer.frame = UIScreen.main.bounds
        if let topLayer = self.layer.sublayers?.first, topLayer is CAGradientLayer
        {
            topLayer.removeFromSuperlayer()
        }
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}
