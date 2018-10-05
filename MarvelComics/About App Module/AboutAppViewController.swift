//
//  AboutAppViewController.swift
//  MarvelComics
//
//  Created by Kovalenko Ilia on 05/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import UIKit

class AboutAppViewController: UIViewController {
    
    @IBOutlet weak var logOutNavigationBar: LogOutNavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        // Do any additional setup after loading the view.
    }
    
    func setupViews() {
        logOutNavigationBar.parentViewController = self
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
