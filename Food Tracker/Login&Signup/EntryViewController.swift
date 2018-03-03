//
//  EntryViewController.swift
//  Food Tracker
//
//  Created by Aaron Chong on 3/2/18.
//  Copyright © 2018 Aaron Chong. All rights reserved.
//

import UIKit

class EntryViewController: UIViewController {

    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var registerView: UIView!
    @IBOutlet weak var loginView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupBackgroundGradient()
        registerView.layer.cornerRadius = 5
        loginView.layer.cornerRadius = 5
        signInButton.layer.cornerRadius = 5
        registerButton.layer.cornerRadius = 5
    }

    private func setupBackgroundGradient() {
        
        let gradient = CAGradientLayer()
        let colorTop = UIColor.white.cgColor
        let colorBottom = UIColor.black.cgColor
        //        let colorTop = UIColor(red: 116.0 / 255.0, green: 71.0 / 255.0, blue: 162.0 / 255.0, alpha: 1.0).cgColor
        //        let colorBottom = UIColor(red: 84.0 / 255.0, green: 94.0 / 255.0, blue: 183.0 / 255.0, alpha: 1.0).cgColor
        
        gradient.frame = view.bounds
        gradient.colors = [colorTop, colorBottom]
        //        gradient.startPoint = CGPoint(x: 1, y: 0)
        //        gradient.endPoint = CGPoint(x: 0, y: 0)
        
        view.layer.insertSublayer(gradient, at: 0)
    }
    
    
    
}
    
