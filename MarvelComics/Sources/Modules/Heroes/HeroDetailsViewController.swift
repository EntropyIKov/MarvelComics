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
    @IBOutlet weak var heroImageView: UIImageView!
    @IBOutlet weak var heroNameLabel: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var pagesSegmentControl: UISegmentedControl!
    
    //MAKR: - Variables
    var hero: Hero!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
    }
    
    func setupViews() {
        
        if let fullpath = hero?.thumbnail?.fullPath {
            let url = URL(string: fullpath)
            heroImageView.kf.setImage(with: url)
        } else {
            heroImageView.image = UIImage(named: "no_image")
        }
        heroImageView.layer.cornerRadius = heroImageView.frame.height/2
        heroImageView.clipsToBounds = true
        heroNameLabel.text = hero.name
        
        let tableView = craeteTableView(frame: viewContainer.frame)
        viewContainer.addSubview(tableView)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log out", style: .plain, target: LogOutService.self, action: #selector(LogOutService.logOut))
    }
    
    func craeteTableView(frame: CGRect) -> UITableView {
        let tableView = UITableView(frame: viewContainer.frame)
        return tableView
    }
    
    @IBAction func segmentControlValueChanged(_ sender: UISegmentedControl) {
        let pageVC = children[0] as! AdditionalDetailsPageViewController
        let pageTables = pageVC.additionalDetailsTableViewControllers
        let newPage = sender.selectedSegmentIndex
        let oldPage = pageVC.currentPage
        let direction = newPage > oldPage ? UIPageViewController.NavigationDirection.forward : .reverse
        pageVC.setViewControllers([pageTables[newPage]!], direction: direction, animated: true, completion: nil)
        pageVC.currentPage = newPage
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AdditionDetailsListSegue" {
            let vc = segue.destination as! AdditionalDetailsPageViewController
            vc.hero = hero
            vc.didFinishAnimationHandler = { index in
                self.pagesSegmentControl.selectedSegmentIndex = index
            }
            vc.currentPage = pagesSegmentControl.selectedSegmentIndex
        }
    }
}
