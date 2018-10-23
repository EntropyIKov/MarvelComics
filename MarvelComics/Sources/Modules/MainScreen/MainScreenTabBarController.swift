//
//  MainScreenTabBarController.swift
//  MarvelComics
//
//  Created by Kovalenko Ilia on 04/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import UIKit

class MainScreenTabBarController: UITabBarController {
    
    //MARK: - Property
    static var storyboardInstance: MainScreenTabBarController {
        let storyboard = UIStoryboard(name: "Heroes", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "MainScreenTabBarController") as! MainScreenTabBarController
    }

    //MARK: - Action
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    //MARK: - Method
    func setupView() {
        delegate = self
        
        let heroListViewController = HeroListViewController.storyboardInstance
        heroListViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log out", style: .plain, target: LogOutService.self, action: #selector(LogOutService.logOut))
        let firstNavigationController = UINavigationController(rootViewController: heroListViewController)
        firstNavigationController.tabBarItem = UITabBarItem(title: "Heroes", image: #imageLiteral(resourceName: "HeroIcon"), tag: 0)
        
        let aboutAppViewController = AboutAppViewController.storyboardInstance
        aboutAppViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log out", style: .plain, target: LogOutService.self, action: #selector(LogOutService.logOut))
        let secondNavigationController = UINavigationController(rootViewController: aboutAppViewController)
        secondNavigationController.tabBarItem = UITabBarItem(title: "About App", image: #imageLiteral(resourceName: "AboutIcon"), tag: 1)
        
        view.tintColor = #colorLiteral(red: 0.9227598906, green: 0.1393100321, blue: 0.1546708345, alpha: 1)
        tabBar.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        tabBar.barTintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
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
