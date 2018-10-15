//
//  EventTableViewController.swift
//  MarvelComics
//
//  Created by Kovalenko Ilia on 12/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import UIKit
import Kingfisher
import CoreData

class EventTableViewController: UITableViewController {
    
    // MARK: - Variables
    var heroId: Int!
    var canLoadNextData = true
    var nextPage = 0
    let backgroundContext = StorageManager.sharedInstance.backgroundContext
    let storageManagerInstance = StorageManager.sharedInstance
    let myDataSource = AdditionalDetailsTableDataSource()
    
    lazy var fetchedResultsController: NSFetchedResultsController<EventCDObject> = {
        let fetchRequest: NSFetchRequest<EventCDObject> = EventCDObject.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "ANY heroes.id = %@", argumentArray: [self.heroId])
        let context = storageManagerInstance.persistentContainer.viewContext
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = myDataSource
        return fetchedResultsController
    }()
    
    lazy var parentsHeroesFetchedResultController: NSFetchedResultsController<HeroCDObject>? = {
        let fetchedResultController = (parent as? AdditionalDetailsPageViewController)?.heroFetchedResultsController
        return fetchedResultController
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.alpha = 1.0
        activityIndicator.center = CGPoint(x: view.frame.width / 2, y: 140)
        return activityIndicator
    }()
    
    // MARK: - Actions
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        getListOfEventsFromCoreData()
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let maxOffset = scrollView.contentSize.height - scrollView.frame.height
        let currentOffset = scrollView.contentOffset.y
        let maxScrollDiff: CGFloat = 100
        if maxOffset > 0, maxOffset - currentOffset < maxScrollDiff {
            getListOfEvents(from: nextPage)
        }
    }
    
    @objc func refreshListOfEvent(_ refreshControl: UIRefreshControl) {
        if let fetchedObjects = fetchedResultsController.fetchedObjects {
            for event in fetchedObjects {
                fetchedResultsController.managedObjectContext.delete(event)
                storageManagerInstance.saveContext()
            }
        }
        if canLoadNextData {
            canLoadNextData = false
            nextPage = 0
            RequestManager.sharedInstance.getEventsDetails(for: heroId, from: nextPage) { [weak self] result in
                switch result {
                case .success(let events):
                    if let self = self {
                        self.parentsHeroesFetchedResultController?.fetchRequest.predicate = NSPredicate(format: "id = %@", argumentArray: [self.heroId])
                        do {
                            try self.parentsHeroesFetchedResultController?.performFetch()
                            let hero = self.parentsHeroesFetchedResultController?.fetchedObjects?.first
                            for event in events {
                                let eventCD = EventCDObject(context: self.backgroundContext)
                                if let id = event.id {
                                    eventCD.id = Int32(id)
                                }
                                if let hero = hero {
                                    eventCD.addToHeroes(hero)
                                }
                                eventCD.pathToImage = event.pathToImage
                                eventCD.title = event.title
                                hero?.addToEvents(eventCD)
                                self.storageManagerInstance.saveContext()
                            }
                        } catch {
                            print(error)
                        }
                    }
                case .failure(let error):
                    print(error)
                }
                if let self = self {
                    self.canLoadNextData = true
                    self.isWorkIndicator(isAnimated: false)
                }
            }
        } else {
            self.isWorkIndicator(isAnimated: false)
        }
    }
    
    // MARK: - Methods
    func setupView() {
        tableView.dataSource = myDataSource
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellWithImageAndLabel")
        myDataSource.tableView = tableView
        myDataSource.fetchedResultsController = (fetchedResultsController as! NSFetchedResultsController<AdditionalDetailsCDObject>)
        
        view.addSubview(activityIndicator)
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshListOfEvent), for: .valueChanged)
        refreshControl?.tintColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        refreshControl?.backgroundColor = .clear
        if let refreshControl = refreshControl {
            tableView.addSubview(refreshControl)
        }
    }
    
    func getListOfEvents(from page: Int) {
        if canLoadNextData {
            canLoadNextData = false
            isWorkIndicator(isAnimated: true)
            
            RequestManager.sharedInstance.getEventsDetails(for: heroId, from: nextPage) { [weak self] result in
                switch result {
                case .success(let events):
                    if let self = self {
                        self.parentsHeroesFetchedResultController?.fetchRequest.predicate = NSPredicate(format: "id = %@", argumentArray: [self.heroId])
                        do {
                            try self.parentsHeroesFetchedResultController?.performFetch()
                            let hero = self.parentsHeroesFetchedResultController?.fetchedObjects?.first
                            for event in events {
                                let eventCD = EventCDObject(context: self.backgroundContext)
                                if let id = event.id {
                                    eventCD.id = Int32(id)
                                }
                                if let hero = hero {
                                    eventCD.addToHeroes(hero)
                                }
                                eventCD.pathToImage = event.pathToImage
                                eventCD.title = event.title
                                hero?.addToEvents(eventCD)
                                self.storageManagerInstance.saveContext()
                            }
                        } catch {
                            print(error)
                        }
                    }
                case .failure(let error):
                    print(error)
                }
                if let self = self {
                    self.canLoadNextData = true
                    self.isWorkIndicator(isAnimated: false)
                }
            }
        }
    }
    
    func getListOfEventsFromCoreData() {
        do {
            try fetchedResultsController.performFetch()
            if let fetchedObjects = fetchedResultsController.fetchedObjects {
                if fetchedObjects.isEmpty {
                    getListOfEvents(from: nextPage)
                } else {
                    nextPage = fetchedObjects.count / 20
                }
            }
        } catch {
            print(error)
        }
    }
    
    func isWorkIndicator(isAnimated: Bool) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = isAnimated
        if let fetchedObjects = fetchedResultsController.fetchedObjects, fetchedObjects.isEmpty && isAnimated {
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false
        } else {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
        }
        if !isAnimated {
            refreshControl?.endRefreshing()
        }
    }
}
