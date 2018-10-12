//
//  CharactersListViewController.swift
//  MarvelComics
//
//  Created by Kovalenko Ilia on 04/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

// Какое поведение при refresh? : clear base
// Как проверять, существует ли запись в core data? predicate
// Загрузку постранично делать с помощью fetchLimit или fetchOffset? : Как хранить загруженные строки? : FRC

import UIKit
import CoreData

class HeroListViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet private weak var charactersCollectionView: UICollectionView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - Variables
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshListOfCharacters), for: .valueChanged)
        refreshControl.tintColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        refreshControl.backgroundColor = .clear
        return refreshControl
    }()
    
    lazy var fetchedResultsController: NSFetchedResultsController<HeroCDObject> = {
        let context = storageManagerInstance.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<HeroCDObject> = HeroCDObject.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    let backgroundContext: NSManagedObjectContext = {
        let context = StorageManager.sharedInstance.backgroundContext
        return context
    }()
    
    let storageManagerInstance = StorageManager.sharedInstance
    var nextPage = 0
    var canLoadNextData = true
    var isOffline = false
    
    //MARK: - Actions
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        getHeroesFromCoreData()
    }
    
    func setupView() {
        isWorkIndicator(isAnimated: false)
        charactersCollectionView.delegate = self
        charactersCollectionView.dataSource = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log out", style: .plain, target: LogOutService.self, action: #selector(LogOutService.logOut))
        charactersCollectionView.addSubview(refreshControl)
    }
    
    @objc func refreshListOfCharacters(_ refreshControl: UIRefreshControl) {
        if let fetchedObjects = fetchedResultsController.fetchedObjects {
            for hero in fetchedObjects {
                fetchedResultsController.managedObjectContext.delete(hero)
                storageManagerInstance.saveContext()
            }
        }
        if canLoadNextData {
            canLoadNextData = false
            nextPage = 0
            
        }
    }
    
    // Methods
    func getHeroesFromCoreData() {
        do {
            try fetchedResultsController.performFetch()
            if let fetchedObjects = fetchedResultsController.fetchedObjects {
                if fetchedObjects.isEmpty {
                    getListOfHeroes(from: nextPage)
                } else {
                    nextPage = fetchedObjects.count / 20
                }
            }
        } catch {
            print(error)
        }
    }
    
    func getListOfHeroes(from page: Int) {
        if canLoadNextData {
            canLoadNextData = false
            isWorkIndicator(isAnimated: true)
            RequestManager.sharedInstance.getHeroes(page: page) { [unowned self] result in
                switch result {
                case .success(let heroes):
                    self.nextPage += 1
                    self.canLoadNextData = true
                    self.isWorkIndicator(isAnimated: false)
                    for hero in heroes {
                        let heroCD = HeroCDObject(context: self.backgroundContext)
                        guard let id = hero.id else {
                            continue
                        }
                        heroCD.id = Int32(id)
                        heroCD.name = hero.name
                        heroCD.pathToImage = hero.pathToImage
                        heroCD.heroDescription = hero.description
                        self.storageManagerInstance.saveContext()
                    }
                case .failure(let error):
                    print(error)
                }
                
            }
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
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowHeroDetails" {
            let selectedHeroCell = sender as! HeroCollectionViewCell
            if let indexPath = charactersCollectionView.indexPath(for: selectedHeroCell) {
                let selectedHero = Hero(by: fetchedResultsController.object(at: indexPath))
                let detailVC = segue.destination as! HeroDetailsViewController
                detailVC.hero = selectedHero
            }
        }
    }
    
}

// UICollectionViewDelegate, UICollectionViewDataSource
extension HeroListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let heroes = fetchedResultsController.fetchedObjects else { return 0 }
        return heroes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let heroCellIdentifier = "HeroCellIdentifier"
        let heroCDObject = fetchedResultsController.object(at: indexPath)
        let hero = Hero(by: heroCDObject)
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: heroCellIdentifier, for: indexPath) as? HeroCollectionViewCell {
            cell.populate(by: hero)
            return cell
        } else {
            fatalError("The dequeued cell is not an instance of \(heroCellIdentifier)")
        }
        
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let maxOffset = scrollView.contentSize.height - scrollView.frame.height
        let currentOffset = scrollView.contentOffset.y
        let maxScrollDiff: CGFloat = 500
        if maxOffset > 0, maxOffset - currentOffset < maxScrollDiff {
            getListOfHeroes(from: nextPage)
        }
    }
}

// NSFetchedResultsControllerDelegate
extension HeroListViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert: 
            charactersCollectionView.reloadData()
        case .delete:
            charactersCollectionView.reloadData()
        case .update: break
        case .move: break
        }
    }
}
