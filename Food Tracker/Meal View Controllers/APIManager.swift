//
//  APIManager.swift
//  Food Tracker
//
//  Created by Aaron Chong on 2/26/18.
//  Copyright © 2018 Aaron Chong. All rights reserved.
//

import UIKit

class APIManager: NSObject {
    
    let userToken = UserDefaults.standard.value(forKey: "foodTrackerToken") as? String ?? ""
    
    // MARK: Saving/Uploading Meal Objects
    
    func saveMealsInAPI(meal: Meal) {
        
        var components = URLComponents(string:"https://cloud-tracker.herokuapp.com")
        components?.path = "/users/me/meals"
        
        let convertedCalories = String(meal.calories)
        let nameQuery = URLQueryItem(name: "title", value: meal.name)
        let caloriesQuery = URLQueryItem(name: "calories", value: convertedCalories)
        let mealDescriptionQuery = URLQueryItem(name: "description", value: meal.mealDescription)
        
        components?.queryItems = [nameQuery, caloriesQuery, mealDescriptionQuery]
        
        let url = components?.url
        guard let urlWithComponents = url else {
            fatalError("Error with combining URL components")
        }
        
        var request = URLRequest(url: urlWithComponents)
        request.addValue(userToken, forHTTPHeaderField: "token")
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
                print("CreateMeal responseString: \(responseString)")
            }
            
            // function to upload image to imgur and return ImageURL
            self.uploadImage(meal: meal, completionHandler: { (urlString: String?) in
                
                // call function to get meal id from data
                if let id = self.getMealIDFromData(data: data), let imageURL = urlString {
    
                    // update rating and imageURL to API
                    self.updateApiWithRatingAndImage(mealID: id, rating: meal.rating, imageUrl: imageURL)
                }
            })
        }
        task.resume()
    }
    
    // Upload image to imgur to get a URL link
    
    private func uploadImage(meal: Meal, completionHandler: @escaping (String?) -> ()) {
        
        guard let mealImage = meal.photo else { return }
        let imageData = UIImagePNGRepresentation(mealImage)
        
        let url = URL(string: "https://api.imgur.com/3/image")
        var request = URLRequest(url: url!)
        request.addValue("Client-ID 887c27b7d390539", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let task = URLSession.shared.uploadTask(with: request, from: imageData) { (data, response, error) in
            
            guard let data = data, error == nil else {
                print("error: \(error!.localizedDescription)")
                return
            }
            
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if statusCode != 200 {
                    print("UploadImage statusCode should be 200, but is \(statusCode)")
                    print("response: \(response!)")
                }
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("uploadMeal responseString: \(responseString)")
            }
            
            var urlString: String?
            defer {                 // defer will always get called before function finishes
                completionHandler(urlString)
            }
            
            do {
                // get created object's id from data
                let json = try JSONSerialization.jsonObject(with: data) as! Dictionary<String,Any>
                guard let data = json["data"] as? Dictionary<String,Any>, let imageURL = data["link"] as? String else {
                    return
                }
                urlString = imageURL
                
            } catch {
                print(#line, error.localizedDescription)
            }
            
        }
        task.resume()
    }
    
    // Need Meal ID to in order to update Rating and Image
    
    private func getMealIDFromData(data: Data) -> Int? {
        
        var mealID: Int?
        do {
            // get created object's id from data
            let json = try JSONSerialization.jsonObject(with: data) as! Dictionary<String,Dictionary<String,Any>>
            guard let jsonMeal = json["meal"], let id = jsonMeal["id"] as? Int else {
                return mealID
            }
            mealID = id
        } catch {
            print(#line, error.localizedDescription)
        }
        return mealID
    }
    
    
    private func updateApiWithRatingAndImage(mealID: Int, rating: Int, imageUrl: String) {
        
        // Update Rating first
        
        guard var components = URLComponents(string: "https://cloud-tracker.herokuapp.com/users/me/meals/\(mealID)/rate") else {return}
        let convertedRating = String(rating)
        let ratingQuery = URLQueryItem(name: "rating", value: convertedRating)
        components.queryItems = [ratingQuery]
        guard let url = components.url else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.addValue(userToken, forHTTPHeaderField: "token")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if (error == nil) {
                // Success
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("UPDATE RATING Session Task Succeeded: HTTP \(statusCode)")
            }
            else {
                // Failure
                print("URL Session Task Failed: %@", error!.localizedDescription);
                return
            }
            
            // Update Image
            
            self.updateImage(mealID: mealID, imageUrl: imageUrl)
            
        })
        task.resume()
    }
    
    
    private func updateImage(mealID: Int, imageUrl: String) {
        
        guard var components = URLComponents(string: "https://cloud-tracker.herokuapp.com/users/me/meals/\(mealID)/photo") else { return }
        
        let photoQuery = URLQueryItem(name: "photo", value: imageUrl)
        components.queryItems = [photoQuery]
        guard let url = components.url else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.addValue(userToken, forHTTPHeaderField: "token")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if (error == nil) {
                // Success
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("Update Image URL Session Task Succeeded: HTTP \(statusCode)")
            }
            else {
                // Failure
                print("URL Session Task Failed: %@", error!.localizedDescription);
                return
            }
        })
        task.resume()
    }
    
    
    
    
    // MARK: Fetching Meal Objects
    
    
    func getMealsFromAPI(completionHandler: @escaping ([Meal]?, Error?) -> Void) {
        
        var components = URLComponents(string:"https://cloud-tracker.herokuapp.com")
        components?.path = "/users/me/meals"
        
        let url = components?.url
        guard let urlWithComponents = url else {
            fatalError("fail to build URL")
        }
        
        var request = URLRequest(url: urlWithComponents)
        request.addValue(userToken, forHTTPHeaderField: "token")
        request.httpMethod = "GET"
        
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
                print("GetMealsFromAPI responseString: \(responseString)")
            }
            
            do {
                guard let mealArrayOfDictionary = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                    print("error serialization")
                    return
                }
                var mealsArray = [Meal]()
                for mealDictionary in mealArrayOfDictionary {
                    
                    let title = mealDictionary["title"] as? String ?? ""
                    let rating = mealDictionary["rating"] as? Int ?? 0
                    let calories = mealDictionary["calories"] as? Int ?? 0
                    let description = mealDictionary["description"] as? String ?? ""
                    let imagePath = mealDictionary["imagePath"] as? String
                    
                    guard let unwrappedImagePath = imagePath else {
                        continue
                    }
                    if let url = URL(string: unwrappedImagePath) {
                        let imageData = try! Data(contentsOf: url)
                        let mealImage = UIImage(data: imageData)
                        
                        let newMeal = Meal(name: title, photo: mealImage, rating: rating, calories: calories, mealDescription: description)
                        if let newMeal = newMeal {
                            mealsArray.append(newMeal)
                        }
                    }
                }
                completionHandler(mealsArray, nil)
            } catch {
                print(#line, error.localizedDescription)
            }
        }
        task.resume()
    }
    
}
