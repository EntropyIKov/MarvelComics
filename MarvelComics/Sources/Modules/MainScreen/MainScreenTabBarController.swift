//
//  MainScreenTabBarController.swift
//  MarvelComics
//
//  Created by Kovalenko Ilia on 04/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import UIKit

class MainScreenTabBarController: UITabBarController {
    
    static var storyboardInstance: MainScreenTabBarController? {
        let storyboard = UIStoryboard(name: "Heroes", bundle: nil)
        return storyboard.instantiateInitialViewController() as? MainScreenTabBarController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        delegate = self
        let storyboard = UIStoryboard(name: "Heroes", bundle: nil)
        let listVC = storyboard.instantiateViewController(withIdentifier: "HeroesListVC") as! HeroListViewController
        let aboutAppVC = storyboard.instantiateViewController(withIdentifier: "AboutAppVC") as! AboutAppViewController
        let firstViewController = UINavigationController(rootViewController: listVC)
        let secondViewController = UINavigationController(rootViewController: aboutAppVC)
        firstViewController.tabBarItem = UITabBarItem(title: "Heroes", image: nil, tag: 0)
        secondViewController.tabBarItem = UITabBarItem(title: "About App", image: nil, tag: 1)
        let tabBarList = [firstViewController, secondViewController]
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
