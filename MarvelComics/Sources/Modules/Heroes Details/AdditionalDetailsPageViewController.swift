//
//  AdditionalDetailsListViewController.swift
//  MarvelComics
//
//  Created by Kovalenko Ilia on 08/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import UIKit
import CoreData

class AdditionalDetailsPageViewController: UIPageViewController {

    var didFinishAnimationHandler: ((Int) -> Void)!
    var hero: Hero!
    var currentPage = 0
    let titles = ["Comics", "Stories", "Events", "Series"]
    
    static weak var storyboardInstance: AdditionalDetailsPageViewController? = {
        let storyboard = UIStoryboard(name: "Heroes", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "AdditionalDetailsPageViewController") as? AdditionalDetailsPageViewController
    }()
    
    lazy var heroFetchedResultsController: NSFetchedResultsController<HeroCDObject> = {
        let context = storageManagerInstance.backgroundContext
        
        let fetchRequest: NSFetchRequest<HeroCDObject> = HeroCDObject.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }()
    
    let backgroundContext: NSManagedObjectContext = {
        let context = StorageManager.sharedInstance.backgroundContext
        return context
    }()
    
    let storageManagerInstance = StorageManager.sharedInstance
    
    
    lazy var childrenTableViewsContollers: [UITableViewController] = {
        return generateNewArrayOfViewController()
    }()
    
    //MARK: - Actions
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        childrenTableViewsContollers = generateNewArrayOfViewController()
        setViewControllers([childrenTableViewsContollers[currentPage]], direction: .forward, animated: true, completion: nil)
    }
    
    //MARK: - Methods
    func generateNewArrayOfViewController() -> [UITableViewController] {
        var array: [UITableViewController] = []
        
        let comicTableViewController = ComicTableViewController()
        comicTableViewController.heroId = hero.id!
        
        let storyTableViewController = StoryTableViewController()
        storyTableViewController.heroId = hero.id!
        
        let eventTableViewController = EventTableViewController()
        eventTableViewController.heroId = hero.id!
        
        let seriesTableViewController = SeriesTableViewController()
        seriesTableViewController.heroId = hero.id!
        
        array = [comicTableViewController,
                 storyTableViewController,
                 eventTableViewController,
                 seriesTableViewController]
        
        return array
    }
}


// UIPageViewControllerDelegate, UIPageViewControllerDataSource
extension AdditionalDetailsPageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? UITableViewController else { return nil }
        if let index = childrenTableViewsContollers.index(of: viewController), index > 0 {
            return childrenTableViewsContollers[index - 1]
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? UITableViewController else { return nil }
        if let index = childrenTableViewsContollers.index(of: viewController), index < titles.count - 1 {
            return childrenTableViewsContollers[index + 1]
        }
        return nil
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let index = childrenTableViewsContollers.index(of: pageViewController.viewControllers![0] as! UITableViewController)!
        currentPage = index
        didFinishAnimationHandler(index)
    }
    
}
