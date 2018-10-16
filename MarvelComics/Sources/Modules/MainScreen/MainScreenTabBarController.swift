//
//  MainScreenTabBarController.swift
//  MarvelComics
//
//  Created by Kovalenko Ilia on 04/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import UIKit

class MainScreenTabBarController: UITabBarController {
    
    static var storyboardInstance: MainScreenTabBarController {
        let storyboard = UIStoryboard(name: "Heroes", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "MainScreenTabBarController") as! MainScreenTabBarController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        delegate = self
        
        let heroListViewController = HeroListViewController.storyboardInstance
        heroListViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log out", style: .plain, target: LogOutService.self, action: #selector(LogOutService.logOut))
        let firstNavigationController = UINavigationController(rootViewController: heroListViewController)
        firstNavigationController.tabBarItem = UITabBarItem(title: "Heroes", image: nil, tag: 0)
        
        let aboutAppViewController = AboutAppViewController.storyboardInstance
        aboutAppViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log out", style: .plain, target: LogOutService.self, action: #selector(LogOutService.logOut))
        let secondNavigationController = UINavigationController(rootViewController: aboutAppViewController)
        secondNavigationController.tabBarItem = UITabBarItem(title: "About App", image: nil, tag: 1)
        
        
        let tabBarList = [firstNavigationController, secondNavigationController]
        viewControllers = tabBarList
    }
    
}

// UITabBarControllerDelegate
extension MainScreenTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let fromView = selectedViewController?.view, let toView = viewController.view else {
            return false
        }

        if fromView != toView {
            UIView.transition(from: fromView,
                              to: toView,
                              duration: 0.3,
                              options: [.transitionCrossDissolve],
                              completion: nil)
        }

        return true
    }
}
