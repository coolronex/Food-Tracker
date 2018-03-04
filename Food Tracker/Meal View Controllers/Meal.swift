//
//  Meal.swift
//  Food Tracker
//
//  Created by Aaron Chong on 2/25/18.
//  Copyright © 2018 Aaron Chong. All rights reserved.
//

import UIKit
import os.log

class Meal: NSObject {
    
    
    //MARK: Properties
    
    var name: String
    var photo: UIImage?
    var rating: Int
    var calories: Int
    var mealDescription: String
    var id: Int
    
    init?(name: String, photo: UIImage?, rating: Int, calories: Int, mealDescription: String, id: Int) {
        
        // The name must not be empty
        guard !name.isEmpty else {
            return nil
        }
        
        // The rating must be between 0 and 5 inclusively
        guard (rating >= 0) && (rating <= 5) else {
            return nil
        }
        
        // Initialize stored properties.
        self.name = name
        self.photo = photo
        self.rating = rating
        self.calories = calories
        self.mealDescription = mealDescription
        self.id = id
    }
    
    
}
