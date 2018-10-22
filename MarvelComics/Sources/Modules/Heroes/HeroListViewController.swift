//
//  CharactersListViewController.swift
//  MarvelComics
//
//  Created by Kovalenko Ilia on 04/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import UIKit
import CoreData
import Kingfisher

class HeroListViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet private weak var charactersCollectionView: UICollectionView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - Variables
    static var storyboardInstance: HeroListViewController {
        let storyboard = UIStoryboard(name: "Heroes", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "HeroListViewController") as! HeroListViewController
    }
    
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
        let context = StorageManager.sharedInstance.heroBackgroundContext
        return context
    }()
    
    let navigationAnimationController = CellToDetailsTransitionOld()
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
        setWorkIndicator(isAnimated: false)
        charactersCollectionView.delegate = self
        charactersCollectionView.dataSource = self
        charactersCollectionView.addSubview(refreshControl)
        navigationController?.delegate = self
    }
    
    @objc func myDismiss() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func refreshListOfCharacters(_ refreshControl: UIRefreshControl) {
        if let fetchedObjects = fetchedResultsController.fetchedObjects {
            for hero in fetchedObjects {
                fetchedResultsController.managedObjectContext.delete(hero)
                storageManagerInstance.saveContext()
            }
        }
        nextPage = 0
        getListOfHeroes(from: nextPage)
    }
    
    // Methods
    func getHeroesFromCoreData() {
        do {
            try fetchedResultsController.performFetch()
            if let fetchedObjects = fetchedResultsController.fetchedObjects {
                if fetchedObjects.isEmpty {
                    getListOfHeroes(from: nextPage)
                } else {
                    nextPage = fetchedObjects.count / RequestManager.getLimit()
                }
            }
        } catch {
            print(error)
        }
    }
    
    func getListOfHeroes(from page: Int) {
        if canLoadNextData {
            canLoadNextData = false
            setWorkIndicator(isAnimated: true)
            RequestManager.sharedInstance.getHeroes(page: page) { [unowned self] result in
                switch result {
                case .success(let heroes):
                    self.nextPage += 1
                    self.canLoadNextData = true
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
                self.canLoadNextData = true
                self.setWorkIndicator(isAnimated: false)
            }
        }
    }
    
    func setWorkIndicator(isAnimated: Bool) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = isAnimated
        if let fetchedObjects = fetchedResultsController.fetchedObjects, fetchedObjects.isEmpty && isAnimated && !refreshControl.isRefreshing {
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false
        } else {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
        }
        
        if !isAnimated {
            refreshControl.endRefreshing()
        }
    }
    
}

// UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension HeroListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellHeigh: CGFloat = 140
        let cellWidth: CGFloat = view.frame.width / 2 - 5
        let cellSize = CGSize(width: cellWidth, height: cellHeigh)
        return cellSize
    }
    
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedHero = Hero(by: fetchedResultsController.object(at: indexPath))
        let heroDetailsViewController = HeroDetailsViewController.storyboardInstance 
        heroDetailsViewController.hero = selectedHero
//        heroDetailsViewController.transitioningDelegate = self
//        navigationController?.present(heroDetailsViewController, animated: true, completion: nil)
        navigationController?.pushViewController(heroDetailsViewController, animated: true)
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

extension HeroListViewController {
    override func didReceiveMemoryWarning() {
        print("warning")
        ImageCache.default.clearMemoryCache()
    }
}

extension HeroListViewController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        guard let selectedIndexPath = charactersCollectionView.indexPathsForSelectedItems?.first else {
            return nil
        }

        let selectedCell = charactersCollectionView.cellForItem(at: selectedIndexPath) as! HeroCollectionViewCell
        
        let imageCenter = selectedCell.getImageViewCenter()
        let yScrollOffset = charactersCollectionView.contentOffset.y
        let startingPoint = CGPoint(x: selectedCell.center.x, y: selectedCell.center.y + imageCenter.y - 8 - yScrollOffset)
        
        navigationAnimationController.startingPoint = startingPoint
        navigationAnimationController.circleColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        switch operation {
        case .push:
            navigationAnimationController.transitionMode = .present
        default:
            navigationAnimationController.transitionMode = .pop
        }
        
        return navigationAnimationController
    }
}

//extension HeroListViewController: UIViewControllerTransitioningDelegate {
//    
//    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        transition.transitionMode = .present
//        
//        guard let selectedIndexPath = charactersCollectionView.indexPathsForSelectedItems?.first else {
//            return nil
//        }
//        
//        let selectedCell = charactersCollectionView.cellForItem(at: selectedIndexPath) as! HeroCollectionViewCell
//        transition.startingPoint = selectedCell.getImageViewCenter()
//        transition.circleColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
//        
//        return transition
//    }
//    
//    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        transition.transitionMode = .dismiss
//        guard let selectedIndexPath = charactersCollectionView.indexPathsForSelectedItems?.first else {
//            return nil
//        }
//        
//        let selectedCell = charactersCollectionView.cellForItem(at: selectedIndexPath) as! HeroCollectionViewCell
//        transition.startingPoint = selectedCell.getImageViewCenter()
//        transition.circleColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
//        
//        return transition
//    }
//    
//}
