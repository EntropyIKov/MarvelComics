//
//  ComicTableViewController.swift
//  MarvelComics
//
//  Created by Kovalenko Ilia on 12/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import UIKit
import Kingfisher
import CoreData

class ComicTableViewController: UITableViewController {
    
    // MARK: - Variable
    var heroId: Int!
    var canLoadNextData = true
    var nextPage = 0
    let backgroundContext = StorageManager.sharedInstance.comicBackgroundContext
    let storageManagerInstance = StorageManager.sharedInstance
    let myDataSource = AdditionalDetailsComicTableDataSource()
    
    lazy var fetchedResultsController: NSFetchedResultsController<ComicCDObject> = {
        let fetchRequest: NSFetchRequest<ComicCDObject> = ComicCDObject.fetchRequest()
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
        let topOffset: CGFloat = 140
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.alpha = 1.0
        activityIndicator.center = CGPoint(x: view.frame.width / 2, y: topOffset)
        
        return activityIndicator
    }()
    
    // MARK: - Action
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        getComicsFromCoreData()
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let maxOffset = scrollView.contentSize.height - scrollView.frame.height
        let currentOffset = scrollView.contentOffset.y
        let maxScrollDiff: CGFloat = 100
        if maxOffset > 0, maxOffset - currentOffset < maxScrollDiff {
            getListOfComics(from: nextPage)
        }
    }
    
    @objc func refreshListOfComics(_ refreshControl: UIRefreshControl) {
        
        if let fetchedObjects = fetchedResultsController.fetchedObjects {
            for comic in fetchedObjects {
                fetchedResultsController.managedObjectContext.delete(comic)
                storageManagerInstance.saveContext()
            }
        }
        
        if canLoadNextData {
            nextPage = 0
            getListOfComics(from: nextPage)
        } else {
            setWorkIndicator(isAnimated: false)
        }
        
    }
    
    // MARK: - Method
    func setupView() {
        tableView.dataSource = myDataSource
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellWithImageAndLabel")
        
        myDataSource.tableView = tableView
        myDataSource.fetchedResultsController = fetchedResultsController
        
        view.addSubview(activityIndicator)
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshListOfComics), for: .valueChanged)
        refreshControl?.tintColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        refreshControl?.backgroundColor = .clear
        
        tableView.addSubview(refreshControl!)
    }
    
    func getListOfComics(from page: Int) {
        if canLoadNextData {
            canLoadNextData = false
            setWorkIndicator(isAnimated: true)
            
            RequestManager.sharedInstance.getComicsDetails(for: heroId, from: nextPage) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let comics):
                    self.parentsHeroesFetchedResultController?.fetchRequest.predicate = NSPredicate(format: "id = %@", argumentArray: [self.heroId])
                    do {
                        
                        try self.parentsHeroesFetchedResultController?.performFetch()
                        let hero = self.parentsHeroesFetchedResultController?.fetchedObjects?.first
                        
                        for comic in comics {
                            let comicCD = ComicCDObject(context: self.backgroundContext)
                            
                            if let id = comic.id {
                                comicCD.id = Int32(id)
                            }
                            
                            if let hero = hero {
                                comicCD.addToHeroes(hero)
                            }
                            
                            if let pageCount = comic.pageCount {
                                comicCD.pageCount = Int32(pageCount)
                            }
                            
                            comicCD.pathToImage = comic.pathToImage
                            comicCD.format = comic.format
                            comicCD.title = comic.title
                            
                            hero?.addToComics(comicCD)
                            
                            self.storageManagerInstance.saveContext()
                        }
                    } catch {
                        print(error)
                    }
                    
                case .failure(let error):
                    print(error)
                }
                
                self.canLoadNextData = true
                self.setWorkIndicator(isAnimated: false)
            }
            
        }
    }
    
    func getComicsFromCoreData() {
        do {
            try fetchedResultsController.performFetch()
            
            if let fetchedObjects = fetchedResultsController.fetchedObjects {
                if fetchedObjects.isEmpty {
                    getListOfComics(from: nextPage)
                } else {
                    nextPage = fetchedObjects.count / RequestManager.getLimit()
                }
            }
        } catch {
            print(error)
        }
    }
    
    func setWorkIndicator(isAnimated: Bool) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = isAnimated
        
        if let fetchedObjects = fetchedResultsController.fetchedObjects, fetchedObjects.isEmpty && isAnimated && !refreshControl!.isRefreshing {
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
