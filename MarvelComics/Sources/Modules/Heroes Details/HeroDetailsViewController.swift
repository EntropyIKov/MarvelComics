//
//  HeroDetailsViewController.swift
//  MarvelComics
//
//  Created by Kovalenko Ilia on 08/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import UIKit
import Kingfisher

class HeroDetailsViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet private weak var heroImageView: UIImageView!
    @IBOutlet private weak var heroNameLabel: UILabel!
    @IBOutlet private weak var viewContainer: UIView!
    @IBOutlet private weak var pagesSegmentControl: UISegmentedControl!
    var pagesVC: AdditionalDetailsPageViewController!
    
    //MAKR: - Variables
    var hero: Hero!
    
    static var storyboardInstance: HeroDetailsViewController = {
        let storyboard = UIStoryboard(name: "Heroes", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "HeroDetailsViewController") as! HeroDetailsViewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews() {
        if let pathToImage = hero.pathToImage, let url = URL(string: pathToImage) {
            let resource = ImageResource(downloadURL: url, cacheKey: "\(pathToImage.hashValue)\(pathToImage)")
            heroImageView.kf.setImage(with: resource)
        } else {
            heroImageView.image = UIImage(named: "no_image")
        }
        
        heroImageView.layer.cornerRadius = heroImageView.frame.height/2
        heroImageView.clipsToBounds = true
        heroNameLabel.text = hero.name
        
        let tableView = craeteTableView(frame: viewContainer.frame)
        viewContainer.addSubview(tableView)
        
        pagesVC = AdditionalDetailsPageViewController.storyboardInstance
        
        pagesVC.hero = hero
        pagesVC.didFinishAnimationHandler = { [unowned self] index in
            self.pagesSegmentControl.selectedSegmentIndex = index
        }
        pagesVC.currentPage = pagesSegmentControl.selectedSegmentIndex
        
        addChild(pagesVC)
        pagesVC.willMove(toParent: self)
        pagesVC.view.frame = viewContainer.bounds
        pagesVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pagesVC.didMove(toParent: self)
        
        viewContainer.addSubview(pagesVC.view)
        
    }
    
    func craeteTableView(frame: CGRect) -> UITableView {
        let tableView = UITableView(frame: viewContainer.frame)
        return tableView
    }
    
    @IBAction func segmentControlValueChanged(_ sender: UISegmentedControl) {
        let pageVC = children[0] as! AdditionalDetailsPageViewController
        let pageTables = pageVC.childrenTableViewsContollers
        let newPage = sender.selectedSegmentIndex
        let oldPage = pageVC.currentPage
        let direction = newPage > oldPage ? UIPageViewController.NavigationDirection.forward : .reverse
        pageVC.setViewControllers([pageTables[newPage]], direction: direction, animated: true, completion: nil)
        pageVC.currentPage = newPage
    }
}
