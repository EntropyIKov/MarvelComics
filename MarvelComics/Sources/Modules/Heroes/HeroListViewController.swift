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
    
    //MARK: - Outlet
    @IBOutlet private weak var charactersCollectionView: UICollectionView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - Property
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
    
    let navigationAnimationController = CellToDetailsTransitionAnimator()
    let storageManagerInstance = StorageManager.sharedInstance
    let spaceBetweenCells: CGFloat = 10
    var nextPage = 0
    var canLoadNextData = true
    var isOffline = false
    
    //MARK: - Action
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        getHeroesFromCoreData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        performChildPopAnimation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        performChildPushAnimation()
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
    
    //MARK: - Method
    func setupView() {
        setWorkIndicator(isAnimated: false)
        charactersCollectionView.delegate = self
        charactersCollectionView.dataSource = self
        charactersCollectionView.addSubview(refreshControl)
        navigationController?.delegate = self
    }
    
    func getSelectedCellCenter() -> CGPoint?{
        guard let selectedCell = getSelectedCollectionCell() else {
            return nil
        }
        
        var imageCenter = selectedCell.center
        let yScrollOffset = charactersCollectionView.contentOffset.y
        imageCenter.y -= yScrollOffset
        
        return imageCenter
    }
    
    func getSelectedCellRect() -> CGRect? {
        guard let selectedCell = getSelectedCollectionCell() else {
            return nil
        }
        let yScrollOffset = charactersCollectionView.contentOffset.y
        let imageCenter = selectedCell.getImageViewCenter()
        let imageCenterWithOffset = CGPoint(x: selectedCell.center.x, y: selectedCell.center.y + imageCenter.y - 8 - yScrollOffset)
        
        let imageSize = selectedCell.getImageViewSize()
        let imageFrame = CGRect(x: imageCenterWithOffset.x - imageSize.width / 2,
                                y: imageCenterWithOffset.y - imageSize.height,
                                width: imageSize.width,
                                height: imageSize.height)
        return imageFrame
    }
    
    func getSelectedCollectionCell() -> HeroCollectionViewCell? {
        guard let selectedIndexPath = charactersCollectionView.indexPathsForSelectedItems?.first else {
            return nil
        }
        
        let selectedCell = charactersCollectionView.cellForItem(at: selectedIndexPath) as! HeroCollectionViewCell
        return selectedCell
    }
    
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
    
    //MARK: Animation
    func performChildPushAnimation() {
        let selectedCell = getSelectedCollectionCell()
        selectedCell?.hideImage(true)
    }
    
    func performChildPopAnimation() {
        let selectedCell = getSelectedCollectionCell()
        selectedCell?.hideImage(false)
    }
    
}
extension HeroListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellHeigh: CGFloat = 140
        let cellWidth: CGFloat = view.frame.width / 2 - spaceBetweenCells / 2
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
    
    //MARK: - UICollectionViewDelegateFlowLayout
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let maxOffset = scrollView.contentSize.height - scrollView.frame.height
        let currentOffset = scrollView.contentOffset.y
        let maxScrollDiff: CGFloat = 500
        if maxOffset > 0, maxOffset - currentOffset < maxScrollDiff {
            getListOfHeroes(from: nextPage)
        }
    }
    
    //MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedHero = Hero(by: fetchedResultsController.object(at: indexPath))
        let heroDetailsViewController = HeroDetailsViewController.storyboardInstance 
        heroDetailsViewController.hero = selectedHero
        heroDetailsViewController.heroListViewController = self
        navigationController?.pushViewController(heroDetailsViewController, animated: true)
    }
    
}

//MARK: - NSFetchedResultsControllerDelegate
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

//MARK: - Did Receive Memory Warning Handler
extension HeroListViewController {
    override func didReceiveMemoryWarning() {
        print("warning")
        ImageCache.default.clearMemoryCache()
    }
}

// MARK: - UINavigationControllerDelegate
extension HeroListViewController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        guard let selectedIndexPath = charactersCollectionView.indexPathsForSelectedItems?.first else {
            return nil
        }

        let selectedCell = charactersCollectionView.cellForItem(at: selectedIndexPath) as! HeroCollectionViewCell
        
        let imageCenter = selectedCell.getImageViewCenter()
        let yScrollOffset = charactersCollectionView.contentOffset.y
        let topOffsetConstraintValue: CGFloat = 8
        let startingPoint = CGPoint(x: selectedCell.center.x, y: selectedCell.center.y + imageCenter.y - topOffsetConstraintValue - yScrollOffset)
        
        navigationAnimationController.startingPoint = startingPoint
        navigationAnimationController.circleColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        switch operation {
        case .push:
            navigationAnimationController.transitionMode = .push
        default:
            navigationAnimationController.transitionMode = .pop
        }
        
        return navigationAnimationController
    }
    
}
