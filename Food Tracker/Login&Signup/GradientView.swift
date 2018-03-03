//
//  GradientView.swift
//  Food Tracker
//
//  Created by Aaron Chong on 3/2/18.
//  Copyright © 2018 Aaron Chong. All rights reserved.
//

import UIKit

@IBDesignable
class GradientView: UIView {
    
    @IBInspectable var direction: String = ""{
        didSet {
            updateView()
        }
    }

    @IBInspectable var firstColor: UIColor = UIColor.clear {
        didSet {
            updateView()
        }
    }
    @IBInspectable var secondColor: UIColor = UIColor.clear {
        didSet {
            updateView()
        }
    }
    
    override class var layerClass: AnyClass {
        get {
            return CAGradientLayer.self
        }
    }
    
    func updateView() {
        
        let layer = self.layer as! CAGradientLayer
        layer.colors = [firstColor, secondColor].map{$0.cgColor}
        
        if direction.caseInsensitiveCompare("horizontal") == ComparisonResult.orderedSame {
            layer.startPoint = CGPoint(x: 0, y: 0.5)
            layer.endPoint = CGPoint (x: 1, y: 0.5)
        }
        if direction.caseInsensitiveCompare("vertical") == ComparisonResult.orderedSame {
            layer.startPoint = CGPoint(x: 0.5, y: 0)
            layer.endPoint = CGPoint (x: 0.5, y: 1)
        }
        if direction.caseInsensitiveCompare("diagonal") == ComparisonResult.orderedSame {
            layer.startPoint = CGPoint(x: 0, y: 0)
            layer.endPoint = CGPoint (x: 1, y: 1)
        }
    }
}


