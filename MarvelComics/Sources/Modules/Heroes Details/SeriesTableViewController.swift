//
//  SeriesTableViewController.swift
//  MarvelComics
//
//  Created by Kovalenko Ilia on 12/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import UIKit
import Kingfisher
import CoreData

class SeriesTableViewController: UITableViewController {
    
    // MARK: - Variables
    var heroId: Int!
    var canLoadNextData = true
    var nextPage = 0
    let backgroundContext = StorageManager.sharedInstance.backgroundContext
    let storageManagerInstance = StorageManager.sharedInstance
    
    lazy var fetchedResultsController: NSFetchedResultsController<SeriesCDObject> = {
        let fetchRequest: NSFetchRequest<SeriesCDObject> = SeriesCDObject.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "ANY heroes.id = %@", argumentArray: [self.heroId])
        let context = storageManagerInstance.persistentContainer.viewContext
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
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
        getListOfSeriesFromCoreData()
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let maxOffset = scrollView.contentSize.height - scrollView.frame.height
        let currentOffset = scrollView.contentOffset.y
        let maxScrollDiff: CGFloat = 100
        if maxOffset > 0, maxOffset - currentOffset < maxScrollDiff {
            getListOfSeries(from: nextPage)
        }
    }
    
    @objc func refreshListOfSeries(_ refreshControl: UIRefreshControl) {
        if let fetchedObjects = fetchedResultsController.fetchedObjects {
            for series in fetchedObjects {
                fetchedResultsController.managedObjectContext.delete(series)
                storageManagerInstance.saveContext()
            }
        }
        if canLoadNextData {
            canLoadNextData = false
            nextPage = 0
            RequestManager.sharedInstance.getSeriesDetails(for: heroId, from: nextPage) { [weak self] result in
                switch result {
                case .success(let seriesStack):
                    if let self = self {
                        self.parentsHeroesFetchedResultController?.fetchRequest.predicate = NSPredicate(format: "id = %@", argumentArray: [self.heroId])
                        do {
                            try self.parentsHeroesFetchedResultController?.performFetch()
                            let hero = self.parentsHeroesFetchedResultController?.fetchedObjects?.first
                            for series in seriesStack {
                                let seriesCD = SeriesCDObject(context: self.backgroundContext)
                                if let id = series.id {
                                    seriesCD.id = Int32(id)
                                }
                                if let hero = hero {
                                    seriesCD.addToHeroes(hero)
                                }
                                seriesCD.pathToImage = series.pathToImage
                                seriesCD.title = series.title
                                hero?.addToSeries(seriesCD)
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
        view.addSubview(activityIndicator)
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshListOfSeries), for: .valueChanged)
        refreshControl?.tintColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        refreshControl?.backgroundColor = .clear
        if let refreshControl = refreshControl {
            tableView.addSubview(refreshControl)
        }
    }
    
    func getListOfSeries(from page: Int) {
        if canLoadNextData {
            canLoadNextData = false
            isWorkIndicator(isAnimated: true)
            
            RequestManager.sharedInstance.getSeriesDetails(for: heroId, from: nextPage) { [weak self] result in
                switch result {
                case .success(let seriesStack):
                    if let self = self {
                        self.parentsHeroesFetchedResultController?.fetchRequest.predicate = NSPredicate(format: "id = %@", argumentArray: [self.heroId])
                        do {
                            try self.parentsHeroesFetchedResultController?.performFetch()
                            let hero = self.parentsHeroesFetchedResultController?.fetchedObjects?.first
                            for series in seriesStack {
                                let seriesCD = SeriesCDObject(context: self.backgroundContext)
                                if let id = series.id {
                                    seriesCD.id = Int32(id)
                                }
                                if let hero = hero {
                                    seriesCD.addToHeroes(hero)
                                }
                                seriesCD.pathToImage = series.pathToImage
                                seriesCD.title = series.title
                                hero?.addToSeries(seriesCD)
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
    
    func getListOfSeriesFromCoreData() {
        do {
            try fetchedResultsController.performFetch()
            if let fetchedObjects = fetchedResultsController.fetchedObjects {
                if fetchedObjects.isEmpty {
                    getListOfSeries(from: nextPage)
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
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let series = fetchedResultsController.fetchedObjects else { return 0 }
        return series.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let reuseIdentifier = "cellWithImageAndLabel"
        var cell: UITableViewCell
        
        let seriesCDObject = fetchedResultsController.object(at: indexPath)
        let series = Series(by: seriesCDObject)
        
        if let oldCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) {
            cell = oldCell
        } else {
            let newCell = UITableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
            cell = newCell
        }
        
        cell.textLabel?.text = series.title
        if let pathToImage = series.pathToImage, let url = URL(string: pathToImage) {
            let resource = ImageResource(downloadURL: url, cacheKey: "\(pathToImage.hashValue)\(pathToImage)")
            cell.imageView?.kf.setImage(with: resource)
        }
        
        return cell
    }
    
}

extension SeriesTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .update: break
        case .move: break
        }
    }
}
