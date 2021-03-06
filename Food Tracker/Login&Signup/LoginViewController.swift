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
    @IBOutlet weak var createAccountView: UIView!
    
    let actInd = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        usernameTextField.backgroundColor = UIColor(red:1.0, green:1.0, blue:1.0, alpha:0.15)
        usernameTextField.textColor = UIColor.white
        usernameTextField.layer.cornerRadius = 5
        
        passwordTextField.backgroundColor = UIColor(red:1.0, green:1.0, blue:1.0, alpha:0.15)
        passwordTextField.textColor = UIColor.white
        passwordTextField.layer.cornerRadius = 5
        
        loginButton.layer.cornerRadius = 5
        loginButton.layer.borderWidth = 2
        loginButton.layer.borderColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.7).cgColor
        
        createAccountView.layer.shadowOffset = CGSize(width: 3, height: -10)
        createAccountView.layer.shadowColor = UIColor.black.cgColor
        createAccountView.layer.shadowRadius = 15.0
        createAccountView.layer.shadowOpacity = 0.8
        createAccountView.backgroundColor = UIColor(red:1.0, green:1.0, blue:1.0, alpha:0.15)
    }

    
    @IBAction func loginTapped(_ sender: UIButton) {
        
        showActivityIndicatory(uiView: view)
        
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
                        
                        self.actInd.stopAnimating()
                        
                        let alert = UIAlertController(title: "Incorrect username or password",
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
                // get token from API
                let json = try JSONSerialization.jsonObject(with: data) as! Dictionary<String,Any>
                guard let token = json["token"] as? String else {
                    return
                }
                
                UserDefaults.standard.set(token, forKey: "foodTrackerToken")
                
                OperationQueue.main.addOperation {
                    self.performSegue(withIdentifier: "loginToMeals", sender: nil)
                }
               
            } catch {
                print(#line, error.localizedDescription)
            }
        }
        task.resume()
    }
    
    // MARK: Private Methods
    
    private func showActivityIndicatory(uiView: UIView) {
        actInd.frame = CGRect(x: 0, y: 0, width: 40.0, height: 40.0)
        actInd.center = uiView.center
        actInd.hidesWhenStopped = true
        actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        uiView.addSubview(actInd)
        actInd.startAnimating()
    }
    
    // MARK: TextField Delegate Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
}
