//
//  LoginViewController.swift
//  Food Tracker
//
//  Created by Aaron Chong on 3/2/18.
//  Copyright © 2018 Aaron Chong. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupBackgroundGradient()
       
        usernameTextField.layer.cornerRadius = 5
        
        usernameTextField.backgroundColor = UIColor(red:1.0, green:1.0, blue:1.0, alpha:0.25)
        usernameTextField.textColor = UIColor(red:0.15, green:0.15, blue:0.15, alpha:1)
        
        passwordTextField.backgroundColor = UIColor(red:1.0, green:1.0, blue:1.0, alpha:0.25)
        passwordTextField.textColor = UIColor.black
        passwordTextField.layer.cornerRadius = 5
        
        loginButton.layer.cornerRadius = 5
        loginButton.layer.borderWidth = 2
        loginButton.layer.borderColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.25).cgColor
    }

    
    @IBAction func loginTapped(_ sender: UIButton) {
        
        var components = URLComponents(string:"https://cloud-tracker.herokuapp.com")
        components?.path = "/login"
        
        let usernameQuery = URLQueryItem(name: "username", value: usernameTextField.text)
        let passwordQuery = URLQueryItem(name: "password", value: passwordTextField.text)
        
        components?.queryItems = [usernameQuery, passwordQuery]
        
        let url = components?.url
        guard let urlWithComponents = url else {
            fatalError("Error with combining URL components")
        }
        
        var request = URLRequest(url: urlWithComponents)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let data = data, error == nil else {
                print("error: \(error!.localizedDescription)")
                return
            }
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if statusCode != 200 {
                    print("statusCode should be 200, but is \(statusCode)")
                    print("response: \(response!)")
                    OperationQueue.main.addOperation {
                        let alert = UIAlertController(title: "Incorrect username/password",
                                                      message: "Please try again",
                                                      preferredStyle: UIAlertControllerStyle.alert)
                        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                        
                        alert.addAction(ok)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("Login responseString: \(responseString)")
            }
            
            do {
                // get created object's id from data
                let json = try JSONSerialization.jsonObject(with: data) as! Dictionary<String,Any>
                guard let token = json["token"] as? String else {
                    return
                }
                print(token)
                
                
            } catch {
                print(#line, error.localizedDescription)
            }
        
        }
        task.resume()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if usernameTextField.text == "" {
            usernameTextField.text = " "
        }
        if passwordTextField.text == "" {
            passwordTextField.text = " "
        }
    }

    private func setupBackgroundGradient() {
        
        let gradient = CAGradientLayer()
//      let colorTop = UIColor.white.cgColor
//      let colorBottom = UIColor.black.cgColor
        let colorTop = UIColor(red: 116.0 / 255.0, green: 71.0 / 255.0, blue: 162.0 / 255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 84.0 / 255.0, green: 94.0 / 255.0, blue: 183.0 / 255.0, alpha: 1.0).cgColor
        
        gradient.frame = view.bounds
        gradient.colors = [colorTop, colorBottom]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        
        view.layer.insertSublayer(gradient, at: 0)
    }
}
