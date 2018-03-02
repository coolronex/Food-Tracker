//
//  RatingControl.swift
//  Food Tracker
//
//  Created by Aaron Chong on 2/24/18.
//  Copyright © 2018 Aaron Chong. All rights reserved.
//

import UIKit

// @IBDesignable builds your programmatically created objects & display in storyboard
@IBDesignable class RatingControl: UIStackView {

    private var ratingButtons = [UIButton]()
    
    var rating = 0 {
        didSet {
            updatedButtonSelectedStates()
        }
    }
    
    
    // specify properties that can then be set in the Attributes inspector using @IBInspectable
    // check stackView's attribute inspector & you'll see a new 'Rating Control' section
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        // adding a property observer to property using didSet
        // everytime a property's value is set/changed, run the methods below
        didSet {
            setupButtons()
        }
    }
    @IBInspectable var starCount: Int = 5 {
        didSet {
            setupButtons()
        }
    }
    
    
    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    //MARK: Button Action
    
    @objc func ratingButtonTapped(button: UIButton) {
        
        // get the button in array of specific index (0 - 4)
        guard let index = ratingButtons.index(of: button) else {
            fatalError("The button, \(button), is not in the ratingButtons array: \(ratingButtons)")
        }
        // calculate the rating of the selected button
        let selectedRating = index + 1 // +1 because you want the current rating to be 1 to 5
        
        if selectedRating == rating {  // If the selected star represents the current rating, reset the rating to 0.
            rating = 0
        } else {
            rating = selectedRating    // Otherwise set the rating to the selected star
        }
        
    }
    
    //MARK: Private Methods
    
    private func updatedButtonSelectedStates() {
        
        for (index, button) in ratingButtons.enumerated() {
            
            // If the index of a button is less than the rating, that button should be selected.
            button.isSelected = index < rating
            
            // Set the hint string for the currently selected star
            let hintString: String?
            if rating == index + 1 {
                hintString = "Tap to reset the rating to zero."
            } else {
                hintString = nil
            }
            
            // Calculate the value string
            let valueString: String
            switch (rating) {
            case 0:
                valueString = "No rating set."
            case 1:
                valueString = "1 star set."
            default:
                valueString = "\(rating) stars set"
            }
            
            // Assign the hint string and value string
            button.accessibilityHint = hintString
            button.accessibilityValue = valueString
        }
    }
    
    private func setupButtons() {
        
        for button in ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        ratingButtons.removeAll() // clear the array with old buttons
        
        /*
        These lines below load the star images from the assets catalog.
        Note that the assets catalog is located in the app’s main bundle. This means that the app can load the images using the shorter UIImage(named:) method.
        However, because the control is @IBDesignable, the setup code also needs to run in Interface Builder.
        For the images to load properly in Interface Builder, you must explicitly specify the catalog’s bundle.
        This ensures that the system can find and load the image.
        */
    
        let bundle = Bundle(for: type(of: self))
        let filledStar = UIImage(named: "filledStar", in: bundle, compatibleWith: self.traitCollection)
        let emptyStar = UIImage(named: "emptyStar", in: bundle, compatibleWith: self.traitCollection)
        let highlightedStar = UIImage(named: "highlightedStar", in: bundle, compatibleWith: self.traitCollection)
        
        for index in 0..<starCount {
            
            // Create the button
            let button = UIButton()
            
            // Set the button images
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            button.setImage(highlightedStar, for: .highlighted)
            button.setImage(highlightedStar, for: [.highlighted, .selected])
            
            // Add constraints
            button.translatesAutoresizingMaskIntoConstraints = false// disable button's generated constraints
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            
            // Set the accessibility label
            button.accessibilityLabel = "Set \(index + 1) star rating"
        
            // Setup the button action
            button.addTarget(self, action: #selector(RatingControl.ratingButtonTapped(button:)), for: .touchUpInside)
            
            // Add the button to the stackView
            addArrangedSubview(button)
            
            // Add the new button to the rating button array
            ratingButtons.append(button)
        }
        updatedButtonSelectedStates()
    }
}
