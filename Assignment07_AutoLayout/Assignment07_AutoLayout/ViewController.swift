//
//  ViewController.swift
//  Assignment07_AutoLayout
//
//  Created by Railan on 29.10.2026.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var postsCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    
    @IBOutlet weak var aboutBodyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = "Railan Baigazy"
        postsCountLabel.text = "128"
        followersCountLabel.text = "4.2K"
        followingCountLabel.text = "312"
        
        aboutBodyLabel.text = """
        Building banking apps in Swift. I like clean architecture, coffee and long walks \
        in the mountains around Almaty. I started with web development, then moved into iOS \
        because I enjoy how much care goes into every small detail of a native app. \
        Outside of work I play the drums, read about software design, and try to ship \
        small side projects on weekends.
        """
    }


}

