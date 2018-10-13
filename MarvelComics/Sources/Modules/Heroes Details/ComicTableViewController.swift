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
    
    // MARK: - Variables
    var heroId: Int!
    var canLoadNextData = true
    var nextPage = 0
    let backgroundContext = StorageManager.sharedInstance.backgroundContext
    let storageManagerInstance = StorageManager.sharedInstance
    
    lazy var fetchedResultsController: NSFetchedResultsController<ComicCDObject> = {
        let fetchRequest: NSFetchRequest<ComicCDObject> = ComicCDObject.fetchRequest()
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
            canLoadNextData = false
            nextPage = 0
            RequestManager.sharedInstance.getComicsDetails(for: heroId, from: nextPage) { [weak self] result in
                switch result {
                case .success(let comics):
                    if let self = self {
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
                        self.isWorkIndicator(isAnimated: false)
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    // MARK: - Methods
    func setupView() {
        view.addSubview(activityIndicator)
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshListOfComics), for: .valueChanged)
        refreshControl?.tintColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        refreshControl?.backgroundColor = .clear
        if let refreshControl = refreshControl {
            tableView.addSubview(refreshControl)
        }
    }
    
    func getListOfComics(from page: Int) {
        if canLoadNextData {
            canLoadNextData = false
            isWorkIndicator(isAnimated: true)
            
            RequestManager.sharedInstance.getComicsDetails(for: heroId, from: nextPage) { [weak self] result in
                switch result {
                case .success(let comics):
                    if let self = self {
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
                        self.isWorkIndicator(isAnimated: false)
                    }
                case .failure(let error):
                    print(error)
                }
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
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let comics = fetchedResultsController.fetchedObjects else { return 0 }
        return comics.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let reuseIdentifier = "cellWithImageAndLabel"
        var cell: UITableViewCell
        
        let comicCDObject = fetchedResultsController.object(at: indexPath)
        let comic = Comic(by: comicCDObject)
        
        if let oldCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) {
            cell = oldCell
        } else {
            let newCell = UITableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
            cell = newCell
        }
        
        cell.textLabel?.text = comic.title
        if let pathToImage = comic.pathToImage, let url = URL(string: pathToImage) {
            let resource = ImageResource(downloadURL: url, cacheKey: "\(pathToImage.hashValue)\(pathToImage)")
            cell.imageView?.kf.setImage(with: resource)
        }

        return cell
    }

}

// NSFetchedResultsControllerDelegate
extension ComicTableViewController: NSFetchedResultsControllerDelegate {
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
