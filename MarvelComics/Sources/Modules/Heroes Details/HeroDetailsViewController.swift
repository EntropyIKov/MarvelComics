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
        
        let storyboard = UIStoryboard(name: "Heroes", bundle: nil)
        pagesVC = storyboard.instantiateViewController(withIdentifier: "AdditionalDetailsPageVC") as? AdditionalDetailsPageViewController

        pagesVC.willMove(toParent: self)
        
        pagesVC.hero = hero
        pagesVC.didFinishAnimationHandler = { [unowned self] index in
            self.pagesSegmentControl.selectedSegmentIndex = index
        }
        pagesVC.currentPage = pagesSegmentControl.selectedSegmentIndex
        
        viewContainer.addSubview(pagesVC.view)
        addChild(pagesVC)
        
        pagesVC.didMove(toParent: self)
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
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "AdditionDetailsListSegue" {
//            let vc = segue.destination as! AdditionalDetailsPageViewController
//            vc.hero = hero
//            vc.didFinishAnimationHandler = { [unowned self] index in
//                self.pagesSegmentControl.selectedSegmentIndex = index
//            }
//            vc.currentPage = pagesSegmentControl.selectedSegmentIndex
//        }
//    }
}
