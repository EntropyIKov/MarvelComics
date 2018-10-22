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
    weak var heroListViewController: HeroListViewController?
    weak var additionalDetailsPageViewController: AdditionalDetailsPageViewController?
    
    //MAKR: - Variables
    var hero: Hero!
    var selectedCellCenter: CGPoint?
    
    static var storyboardInstance: HeroDetailsViewController {
        let storyboard = UIStoryboard(name: "Heroes", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "HeroDetailsViewController") as! HeroDetailsViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.bringSubviewToFront(heroImageView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupViews()
        if let selectedCellFrame = heroListViewController?.getSelectedCellRect(),
            var selectedCellCenter = heroListViewController?.getSelectedCellCenter(){
            for subview in view.subviews {
                if subview is UIImageView { continue }
                subview.transform = CGAffineTransform(translationX: 400, y: 0)
            }
            let errorOffset: CGFloat = 3 // Без него view дергается
            
            selectedCellCenter.y += errorOffset
            let originCenter = heroImageView.center
            let originFrame = heroImageView.frame
            
            let xScale = selectedCellFrame.width / originFrame.width
            let yScale = selectedCellFrame.height / originFrame.height
            
            heroImageView.center = selectedCellCenter
            heroImageView.transform = CGAffineTransform(scaleX: xScale, y: yScale)

            transitionCoordinator?.animateAlongsideTransition(in: view, animation: { [unowned self] context in
                self.heroImageView.center = originCenter
                for subview in self.view.subviews {
                    subview.transform = CGAffineTransform.identity
                }
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let selectedCellFrame = heroListViewController?.getSelectedCellRect(),
            var selectedCellCenter = heroListViewController?.getSelectedCellCenter(){
            let originFrame = heroImageView.frame
            
            let xScale = selectedCellFrame.width / originFrame.width
            let yScale = selectedCellFrame.height / originFrame.height
            
            let errorOffset: CGFloat = 2 // Без него view дергается
            selectedCellCenter.y += selectedCellFrame.height / 2 + errorOffset
            transitionCoordinator?.animateAlongsideTransition(in: view, animation: { [unowned self] context in
                self.heroImageView.center = selectedCellCenter
                for subview in self.view.subviews {
                    if subview is UIImageView {
                        subview.transform = CGAffineTransform(scaleX: xScale, y: yScale)
                        continue
                    }
                    subview.transform = CGAffineTransform(translationX: 400, y: 0)
                }
            })
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if let child = additionalDetailsPageViewController {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
    }
    
    func setupViews() {
        heroNameLabel.text = hero.name
        setImageView()
        setChildViewController()
    }
    
    func setImageView() {
        heroImageView.layer.cornerRadius = heroImageView.frame.height/2
        heroImageView.clipsToBounds = true
        
        if let pathToImage = hero.pathToImage, let url = URL(string: pathToImage) {
            heroImageView.kf.setImage(with: url, completionHandler: { [weak self] (image, error, cacheType, imageUrl) in
                guard let _ = image else {
                    self?.heroImageView.image = UIImage(named: "no_image")
                    return 
                }
            })
        }
    }
    
    func setChildViewController() {
        additionalDetailsPageViewController = AdditionalDetailsPageViewController.storyboardInstance
        if let additionalDetailsPageViewController = additionalDetailsPageViewController {
            self.pagesSegmentControl.selectedSegmentIndex = 0
            
            additionalDetailsPageViewController.hero = hero
            additionalDetailsPageViewController.currentPage = pagesSegmentControl.selectedSegmentIndex
            additionalDetailsPageViewController.didFinishAnimationHandler = { [unowned self] index in
                self.pagesSegmentControl.selectedSegmentIndex = index
            }
            
            addChild(additionalDetailsPageViewController)
            additionalDetailsPageViewController.willMove(toParent: self)
            additionalDetailsPageViewController.view.frame = viewContainer.bounds
            additionalDetailsPageViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            additionalDetailsPageViewController.didMove(toParent: self)
            
            viewContainer.addSubview(additionalDetailsPageViewController.view)
        }
        
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
