//
//  MealTableViewCell.swift
//  Food Tracker
//
//  Created by Aaron Chong on 2/25/18.
//  Copyright © 2018 Aaron Chong. All rights reserved.
//

import UIKit

class MealTableViewCell: UITableViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var nameLabel: UILabel!
    
    var meal: Meal! {
        didSet {
           self.configureCell()
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func configureCell() {
        nameLabel.text = meal.name
        ratingControl.rating = meal.rating
        photoImageView.image = meal.photo
    }
}
