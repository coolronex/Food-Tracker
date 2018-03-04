//
//  SignupViewController.swift
//  Food Tracker
//
//  Created by Aaron Chong on 3/3/18.
//  Copyright © 2018 Aaron Chong. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController, UITextFieldDelegate {

    enum MessageTitle:String {
       
        case emptyUsername = "Username field is empty"
        case emptyPassword = "Password field is empty"
        case unmatchedPassword = "Password does not match"
    }
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var retypePasswordTextField: UITextField!
    @IBOutlet weak var createAccountButton: UIButton!
    
    let actInd = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.backgroundColor = UIColor(red:1.0, green:1.0, blue:1.0, alpha:0.15)
        usernameTextField.textColor = UIColor.white
        usernameTextField.layer.cornerRadius = 5
        
        passwordTextField.backgroundColor = UIColor(red:1.0, green:1.0, blue:1.0, alpha:0.15)
        passwordTextField.textColor = UIColor.white
        passwordTextField.layer.cornerRadius = 5
        
        retypePasswordTextField.backgroundColor = UIColor(red:1.0, green:1.0, blue:1.0, alpha:0.15)
        retypePasswordTextField.textColor = UIColor.white
        retypePasswordTextField.layer.cornerRadius = 5
        
        createAccountButton.layer.cornerRadius = 5
        createAccountButton.layer.borderWidth = 2
        createAccountButton.layer.borderColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.7).cgColor
    }

    @IBAction func createAccountTapped(_ sender: UIButton) {
        
        showActivityIndicatory(uiView: view)
        
        if usernameTextField.text == "" {
            usernamePasswordRequirementCheck(titleMessage: MessageTitle.emptyUsername.rawValue)
            return
        }
        
        if passwordTextField.text == "" {
            usernamePasswordRequirementCheck(titleMessage: MessageTitle.emptyPassword.rawValue)
            return
        }
        
        if passwordTextField.text != retypePasswordTextField.text {
            usernamePasswordRequirementCheck(titleMessage: MessageTitle.unmatchedPassword.rawValue)
            return
        }
        
        var components = URLComponents(string:"https://cloud-tracker.herokuapp.com")
        components?.path = "/signup"
        
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
                        
                        let alert = UIAlertController(title: "Username already exists",
                                                      message: "Please choose a new username",
                                                      preferredStyle: UIAlertControllerStyle.alert)
                        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                        
                        alert.addAction(ok)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
    
            if let responseString = String(data: data, encoding: .utf8) {
                print("Signup responseString: \(responseString)")
            }
            
            do {
                // get token from API
                let json = try JSONSerialization.jsonObject(with: data) as! Dictionary<String,Any>
                guard let token = json["token"] as? String else {
                    return
                }
                
                UserDefaults.standard.set(token, forKey: "foodTrackerToken")
                
                OperationQueue.main.addOperation {
                    self.performSegue(withIdentifier: "signupToMeals", sender: nil)
                }
                
            } catch {
                print(#line, error.localizedDescription)
            }
            
        }
        task.resume()
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    // MARK: Private Methods
    
    private func usernamePasswordRequirementCheck(titleMessage: String) {
        
        self.actInd.stopAnimating()
        let alert = UIAlertController(title: titleMessage,
                                      message: "Please try again",
                                      preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    
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
