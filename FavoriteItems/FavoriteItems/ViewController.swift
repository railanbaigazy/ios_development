//
//  ViewController.swift
//  FavoriteItems
//
//  Created by Railan on 14.10.2026.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var nextButton: UIButton!
    
    let exercises: [String:UIImage] = [
        "Squats": .squats,
        "Barbell Romanian Deadlift": .bbRdl,
        "Incline Dumbbell Press": .inclineDbPress,
        "Pullups": .pullups,
        "Wide-grip pulley row": .wideGripPulleyRow,
        "Bench press": .benchPress
    ]
    var currentExercise: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        image.image = .placeholder
        label.text = ""
        nextButton.setTitle("Get Random", for: .normal)
    }
    
    @IBAction func onNextButtonClick(_ sender: UIButton) {
        guard let exercise = exercises
            .filter({ $0.key != currentExercise })
            .randomElement() else { return }
        
        currentExercise = exercise.key
        image.image = exercise.value
        label.text = exercise.key
        nextButton.setTitle("Next", for: .normal)
    }
}

