//
//  FoodTrackerVC.swift
//  Food Tracker
//
//  Created by Aaron Chong on 2/24/18.
//  Copyright © 2018 Aaron Chong. All rights reserved.
//

import UIKit

// This imports the unified logging system.
// Like the print() function, the unified logging system lets you send messages to the console.
// However, the unified logging system gives you more control over when messages appear and how they are saved.
import os.log

class MealViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var meal: Meal?
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var caloriesTextField: UITextField!
    @IBOutlet weak var mealDescriptionTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        
        // Set up views if editing an existing Meal.
        if let meal = meal {
            navigationItem.title = meal.name
            nameTextField.text = meal.name
            photoImageView.image = meal.photo
            ratingControl.rating = meal.rating
            mealDescriptionTextField.text = meal.mealDescription
            caloriesTextField.text = String(meal.calories)
        }
        
        // Enable the Save button only if the text field has a valid Meal name
        updateSaveButtonState()
        
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // tells the textField that keyboard should hide after user hits return button
        textField.resignFirstResponder()
        return true
    }
   
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        // Disable the Save button while editing.
        saveButton.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        updateSaveButtonState()
        navigationItem.title = textField.text
    }
    
    //MARK: UIPickerControllerDelegate
    
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        // hide keyboard to ensure that user decides to tap on image while typing on textField
        nameTextField.resignFirstResponder()
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary // only allows pictures to be picked, not taken
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    // gets called when user taps image picker's CANCEL button to dismiss pickerController
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        photoImageView.image = selectedImage
        dismiss(animated: true, completion: nil) // always remember pickerController to dismiss after user picks image
        
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        // The nil coalescing operator is used to return the value of an optional if the optional has a value, or return a default value otherwise
        // Here, the operator unwraps the optional String returned by nameTextField.text (which is optional because there may or may not be text in the text field), and returns that value if it’s a valid string.
        // But if it’s nil, the operator the returns the empty string ("") instead.
        let name = nameTextField.text ?? ""
        let photo = photoImageView.image
        let rating = ratingControl.rating
        let calories = Int(caloriesTextField.text!)
        let mealDescription = mealDescriptionTextField.text
        
        // Set the meal to be passed to MealTableViewController after the unwind segue.
        meal = Meal(name: name, photo: photo, rating: rating, calories: calories!, mealDescription: mealDescription!)
        
        
        
        // Saving Meal object to API (REFACTOR LATER)
        
        var components = URLComponents(string:"https://cloud-tracker.herokuapp.com")
        components?.path = "/users/me/meals"
        
        guard let unwrappedCalories = calories, let unwrappedMealDescription = mealDescription else {
            fatalError("properties are nil")
        }
        let convertedCalories = String(unwrappedCalories)
        let nameQuery = URLQueryItem(name: "title", value: name)
        let caloriesQuery = URLQueryItem(name: "calories", value: convertedCalories)
        let mealDescriptionQuery = URLQueryItem(name: "description", value: unwrappedMealDescription)
        components?.queryItems = [nameQuery, caloriesQuery, mealDescriptionQuery]

        let url = components?.url
        guard let urlWithComponents = url else {
            fatalError("Error with combining URL components")
        }
        
        var request = URLRequest(url: urlWithComponents)
        request.addValue("2fR8hefxBqvMenHQ5vum226Q", forHTTPHeaderField: "token")
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
                }
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
            print("responseString: \(responseString)")
            }
            
            do {
                // get created object's id from data
                let json = try JSONSerialization.jsonObject(with: data) as! Dictionary<String,Dictionary<String,Any>>
                guard let meal = json["meal"], let id = meal["id"] as? Int else {
                    return
                }
                // make another request with the ratings using the id value
                self.updateMealRatingToAPI(mealID: id, rating: rating)
                
            } catch {
                print(#line, error.localizedDescription)
            }
        }
        task.resume()
    }
    
    
    // PRIVATE REQUEST TO UPDATE RATING (REFACTOR)
    
    private func updateMealRatingToAPI(mealID: Int, rating: Int) {

        guard var components = URLComponents(string: "https://cloud-tracker.herokuapp.com/users/me/meals/\(mealID)/rate") else {return}
        let convertedRating = String(rating)
        let ratingQuery = URLQueryItem(name: "rating", value: convertedRating)
        components.queryItems = [ratingQuery]
        guard let URL = components.url else {return}
        var request = URLRequest(url: URL)
        request.httpMethod = "POST"
        
        request.addValue("2fR8hefxBqvMenHQ5vum226Q", forHTTPHeaderField: "token")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if (error == nil) {
                // Success
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("URL Session Task Succeeded: HTTP \(statusCode)")
            }
            else {
                // Failure
                print("URL Session Task Failed: %@", error!.localizedDescription);
            }
        })
        task.resume()
    }
    
    
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        
        if isPresentingInAddMealMode {
            dismiss(animated: true, completion: nil)
        }
        else if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The MealViewController is not inside a navigation controller.")
        }
    }
    
    
    // MARK: Private Functions
    
    private func updateSaveButtonState() {
        
        let text = nameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
    
    
    
    
    
    
}
