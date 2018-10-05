//
//  LogOutNavigationBar.swift
//  MarvelComics
//
//  Created by Kovalenko Ilia on 05/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import UIKit

class LogOutNavigationBar: UINavigationBar {
    
    var parentViewController: UIViewController!
    
    @IBAction func logOutButtonPressed(_ sender: UIBarButtonItem) {
        parentViewController.performSegue(withIdentifier: "LogOutSegue", sender: nil)
    }
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
