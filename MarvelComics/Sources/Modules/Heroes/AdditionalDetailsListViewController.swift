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
    lazy var additionaDetailsTableViewControllers : [AdditionalDetailsTableViewController] = {
        var additionalDetailsTableVC = [AdditionalDetailsTableViewController]()
        if let comics = hero.comics?.items {
            additionalDetailsTableVC.append(AdditionalDetailsTableViewController(with: comics))
        }
        if let stories = hero.stories?.items {
            additionalDetailsTableVC.append(AdditionalDetailsTableViewController(with: stories))
        }
        if let events = hero.events?.items {
            additionalDetailsTableVC.append(AdditionalDetailsTableViewController(with: events))
        }
        if let series = hero.series?.items {
            additionalDetailsTableVC.append(AdditionalDetailsTableViewController(with: series))
        }
        return additionalDetailsTableVC
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        dataSource = self
        setViewControllers([additionaDetailsTableViewControllers[currentPage]], direction: .forward, animated: true, completion: nil)
    }
}


// UIPageViewControllerDelegate, UIPageViewControllerDataSource
extension AdditionalDetailsPageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? AdditionalDetailsTableViewController else {
            return nil
        }
        if let index = additionaDetailsTableViewControllers.index(of: viewController), index > 0 {
            return additionaDetailsTableViewControllers[index - 1]
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? AdditionalDetailsTableViewController else {
            return nil
        }
        if let index = additionaDetailsTableViewControllers.index(of: viewController), index < titles.count - 1 {
            return additionaDetailsTableViewControllers[index + 1]
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
        let index = additionaDetailsTableViewControllers.index(of: pageViewController.viewControllers![0] as! AdditionalDetailsTableViewController)!
        currentPage = index
        didFinishAnimationHandler(index)
    }
    
}
