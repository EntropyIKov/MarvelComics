//
//  AdditionalDetailsListViewController.swift
//  MarvelComics
//
//  Created by Kovalenko Ilia on 08/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import UIKit

class AdditionalDetailsPageViewController: UIPageViewController {

    var didFinishAnimationHandler: ((Int) -> Void)!
    var hero: Hero!
    var currentPage = 0
    let titles = ["Comics", "Stories", "Events", "Series"]
    
    lazy var additionalDetailsTableViewControllers: [AdditionalDetailsTableViewController?] = {
        var arrayVC = [AdditionalDetailsTableViewController]()
        if let heroId = hero.id {
            arrayVC.append(AdditionalDetailsTableViewController(with: heroId, type: .Comic))
            arrayVC.append(AdditionalDetailsTableViewController(with: heroId, type: .Story))
            arrayVC.append(AdditionalDetailsTableViewController(with: heroId, type: .Event))
            arrayVC.append(AdditionalDetailsTableViewController(with: heroId, type: .Series))
        }
        return arrayVC
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        dataSource = self
        setViewControllers([additionalDetailsTableViewControllers[currentPage]!], direction: .forward, animated: true, completion: nil)
    }
}


// UIPageViewControllerDelegate, UIPageViewControllerDataSource
extension AdditionalDetailsPageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? AdditionalDetailsTableViewController else {
            return nil
        }
        if let index = additionalDetailsTableViewControllers.index(of: viewController), index > 0 {
            return additionalDetailsTableViewControllers[index - 1]
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? AdditionalDetailsTableViewController else {
            return nil
        }
        if let index = additionalDetailsTableViewControllers.index(of: viewController), index < titles.count - 1 {
            return additionalDetailsTableViewControllers[index + 1]
        }
        return nil
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return titles.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let index = additionalDetailsTableViewControllers.index(of: pageViewController.viewControllers![0] as? AdditionalDetailsTableViewController)!
        currentPage = index
        didFinishAnimationHandler(index)
    }
    
}
