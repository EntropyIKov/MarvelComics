//
//  CharactersListViewController.swift
//  MarvelComics
//
//  Created by Kovalenko Ilia on 04/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import UIKit

class HeroListViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var charactersCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - Variables
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshListOfCharacters), for: .valueChanged)
        refreshControl.tintColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        return refreshControl
    }()
    var heroes: [Hero] = []
    var nextPage = 0
    var canLoadNextData = true
    
    //MARK: - Actions
    override func viewDidLoad() {
//        super.viewDidLoad()
        setupView()
        getListOfCharacter(from: nextPage)
    }
    
    func setupView() {
        isWorkIndicator(isAnimated: false)
        charactersCollectionView.delegate = self
        charactersCollectionView.dataSource = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log out", style: .plain, target: LogOutService.self, action: #selector(LogOutService.logOut))
        charactersCollectionView.addSubview(refreshControl)
    }
    
    func getListOfCharacter(from page: Int) {
        if canLoadNextData {
            canLoadNextData = false
            isWorkIndicator(isAnimated: true)
            RequestManager.sharedInstance.getCharacters(page: page) { characters in
                self.heroes.insert(contentsOf: characters, at: self.heroes.count)
                self.nextPage += 1
                self.charactersCollectionView.reloadData()
                self.canLoadNextData = true
                self.isWorkIndicator(isAnimated: false)
            }
        }
    }
    
    @objc func refreshListOfCharacters(_ refreshControl: UIRefreshControl) {
        if canLoadNextData {
            canLoadNextData = false
            nextPage = 0
            heroes.removeAll()
            charactersCollectionView.reloadData()
            RequestManager.sharedInstance.getCharacters(page: nextPage) { characters in
                self.heroes.insert(contentsOf: characters, at: self.heroes.count)
                self.nextPage += 1
                self.charactersCollectionView.reloadData()
                self.canLoadNextData = true
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowHeroDetails" {
            guard let selectedHeroCell = sender as? HeroCollectionViewCell else {
                fatalError()
            }
            guard let indexPathRow = charactersCollectionView.indexPath(for: selectedHeroCell)?.row else {
                fatalError()
            }
            
            let selectedHero = heroes[indexPathRow]
            let detailVC = segue.destination as! HeroDetailsViewController
            detailVC.hero = selectedHero
        }
        
    }
    
    func isWorkIndicator(isAnimated: Bool) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = isAnimated
        if isAnimated && heroes.isEmpty {
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false
        } else {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
        }
    }
    
}

// UICollectionViewDelegate, UICollectionViewDataSource
extension HeroListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return heroes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let heroCellIdentifier = "HeroCellIdentifier"
        let hero = heroes[indexPath.row]
        
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
            getListOfCharacter(from: nextPage)
        }
    }
}
