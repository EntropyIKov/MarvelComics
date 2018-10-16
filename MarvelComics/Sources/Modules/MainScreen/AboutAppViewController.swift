//
//  AboutAppViewController.swift
//  MarvelComics
//
//  Created by Kovalenko Ilia on 15/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import UIKit

class AboutAppViewController: UIViewController {
    
    static var storyboardInstance: AboutAppViewController {
        let storyboard = UIStoryboard(name: "Heroes", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "AboutAppViewController") as! AboutAppViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
