//
//  MealTableViewController.swift
//  Food Tracker
//
//  Created by Aaron Chong on 2/25/18.
//  Copyright © 2018 Aaron Chong. All rights reserved.
//

import UIKit
import os.log

class MealTableViewController: UITableViewController {

    var meals = [Meal]()
    var apiManager = APIManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = editButtonItem
        apiManager.getMealsFromAPI { (meals, error) in
            if let error = error {
                print("Error: \(error)")
            }
            guard let meals = meals else {
                print("Error getting pokemon")
                return
            }
            self.meals = meals
            OperationQueue.main.addOperation {
                self.tableView.reloadData()
            }
        }
        
        
        
        
//        var components = URLComponents(string:"https://cloud-tracker.herokuapp.com")
//        components?.path = "/users/me/meals"
//
//        let url = components?.url
//        guard let urlWithComponents = url else {
//            return
//        }
//
//        var request = URLRequest(url: urlWithComponents)
//        request.addValue("2fR8hefxBqvMenHQ5vum226Q", forHTTPHeaderField: "token")
//        request.httpMethod = "GET"
//
//        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
//
//            guard let data = data, error == nil else {
//                print("error: \(error!.localizedDescription)")
//                return
//            }
//
//            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
//                if statusCode != 200 {
//                    print("statusCode should be 200, but is \(statusCode)")
//                    print("response: \(response!)")
//                }
//            }
//
//            if let responseString = String(data: data, encoding: .utf8) {
//                print("responseString: \(responseString)")
//            }
//
//            do {
//                guard let mealArrayOfDictionary = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
//                    print("error serialization")
//                    return
//                }
//
//                for mealDictionary in mealArrayOfDictionary {
//
//                    let title = mealDictionary["title"] as? String ?? ""
//                    let rating = mealDictionary["rating"] as? Int ?? 0
//                    let calories = mealDictionary["calories"] as? Int ?? 0
//                    let description = mealDictionary["description"] as? String ?? ""
//                    let image = mealDictionary["imagePath"] as? UIImage ?? UIImage(named:"defaultPhoto")
//                    let newMeal = Meal(name: title, photo: image, rating: rating, calories: calories, mealDescription: description)
//                    if let newMeal = newMeal {
//                        self.meals.append(newMeal)
//                    }
//                }
//                OperationQueue.main.addOperation {
//                    self.tableView.reloadData()
//                }
//
//            } catch {
//                print(#line, error.localizedDescription)
//            }
//        }
//        task.resume()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return meals.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "MealTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MealTableViewCell  else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        
        let meal = meals[indexPath.row]
        cell.meal = meal
        
        return cell
    }


    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            // Delete the row from the data source
            meals.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            
        }    
    }
 

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
       
        switch (segue.identifier ?? "") {
        case "AddItem":
            os_log("Adding a new meal.", log: OSLog.default, type: .debug)
        
        case "ShowDetail":
            guard let mealDetailViewController = segue.destination as? MealViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedMealCell = sender as? MealTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedMealCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedMeal = meals[indexPath.row]
            mealDetailViewController.meal = selectedMeal
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }

    // MARK: Actions
    
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        // request to fetch everything
        if let sourceViewController = sender.source as? MealViewController, let meal = sourceViewController.meal {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                meals[selectedIndexPath.row] = meal
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
                
            } else {
                let newIndexPath = IndexPath(row: meals.count, section: 0)
                meals.append(meal)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        }
    }
    
    
     // MARK: Private Methods
    
//    private func loadSampleMeals() {
//
//        let photo1 = UIImage(named: "meal1")
//        let photo2 = UIImage(named: "meal2")
//        let photo3 = UIImage(named: "meal3")
//
//        guard let meal1 = Meal(name: "Caprese Salad", photo: photo1, rating: 4, calories: 50, mealDescription: "salad") else {
//            fatalError("Unable to instantiate meal1")
//        }
//        guard let meal2 = Meal(name: "Chicken and Potatoes", photo: photo2, rating: 5, calories: 120, mealDescription: "baked") else {
//            fatalError("Unable to instantiate meal2")
//        }
//        guard let meal3 = Meal(name: "Pasta with Meatballs", photo: photo3, rating: 3, calories: 100, mealDescription: "sphagetti") else {
//             fatalError("Unable to instantiate meal3")
//        }
//
//        meals += [meal1, meal2, meal3]
//    }
}
