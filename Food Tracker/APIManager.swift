//
//  APIManager.swift
//  Food Tracker
//
//  Created by Aaron Chong on 2/26/18.
//  Copyright © 2018 Aaron Chong. All rights reserved.
//

import UIKit

class APIManager: NSObject {
    
    func saveMealsInAPI(mealName: String, calories: Int, description: String, rating: Int) {
        
        var components = URLComponents(string:"https://cloud-tracker.herokuapp.com")
        components?.path = "/users/me/meals"
        
        let convertedCalories = String(calories)
        let nameQuery = URLQueryItem(name: "title", value: mealName)
        let caloriesQuery = URLQueryItem(name: "calories", value: convertedCalories)
        let mealDescriptionQuery = URLQueryItem(name: "description", value: description)
        
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
    
    func getMealsFromAPI(completionHandler: @escaping ([Meal]?, Error?) -> Void) {
        
        var components = URLComponents(string:"https://cloud-tracker.herokuapp.com")
        components?.path = "/users/me/meals"
        
        let url = components?.url
        guard let urlWithComponents = url else {
            fatalError("fail to build URL")
        }
        
        var request = URLRequest(url: urlWithComponents)
        request.addValue("2fR8hefxBqvMenHQ5vum226Q", forHTTPHeaderField: "token")
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
                print("responseString: \(responseString)")
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
                    let image = mealDictionary["imagePath"] as? UIImage ?? UIImage(named:"defaultPhoto")
                    let newMeal = Meal(name: title, photo: image, rating: rating, calories: calories, mealDescription: description)
                    if let newMeal = newMeal {
                        mealsArray.append(newMeal)
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
