//
//  AboutAppViewController.swift
//  MarvelComics
//
//  Created by Kovalenko Ilia on 15/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import UIKit

class AboutAppViewController: UIViewController {
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log out", style: .plain, target: LogOutService.self, action: #selector(LogOutService.logOut))
    }
}