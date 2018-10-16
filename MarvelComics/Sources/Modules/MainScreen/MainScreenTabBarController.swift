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
        return storyboard.instantiateInitialViewController() as! MainScreenTabBarController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        delegate = self
        
        
//        let listViewController = storyboard.instantiateViewController(withIdentifier: "HeroesListVC") as! HeroListViewController
//        let listNavigationController = UINavigationController(rootViewController: listViewController)
//        listNavigationController.tabBarItem = UITabBarItem(title: "Heroes", image: nil, tag: 0)

//        viewControllers = [listNavigationController]
        
        
        
        let storyboard = UIStoryboard(name: "Heroes", bundle: nil)
        let listVC = storyboard.instantiateViewController(withIdentifier: "HeroListViewController") as! HeroListViewController
        let aboutAppVC = storyboard.instantiateViewController(withIdentifier: "AboutAppViewController") as! AboutAppViewController
        let firstNavigationController = UINavigationController(rootViewController: listVC)
        let secondNavigationController = UINavigationController(rootViewController: aboutAppVC)
        firstNavigationController.tabBarItem = UITabBarItem(title: "Heroes", image: nil, tag: 0)
        secondNavigationController.tabBarItem = UITabBarItem(title: "About App", image: nil, tag: 1)
        listVC.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log out", style: .plain, target: LogOutService.self, action: #selector(LogOutService.logOut))
        aboutAppVC.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log out", style: .plain, target: LogOutService.self, action: #selector(LogOutService.logOut))
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
