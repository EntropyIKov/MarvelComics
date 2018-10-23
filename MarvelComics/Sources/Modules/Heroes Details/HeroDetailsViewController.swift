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
    
    //MARK: - Outlet
    @IBOutlet private weak var heroImageView: UIImageView!
    @IBOutlet private weak var heroNameLabel: UILabel!
    @IBOutlet private weak var viewContainer: UIView!
    @IBOutlet private weak var pagesSegmentControl: UISegmentedControl!
    weak var heroListViewController: HeroListViewController?
    weak var additionalDetailsPageViewController: AdditionalDetailsPageViewController?
    
    //MAKR: - Variable
    var hero: Hero!
    var selectedCellCenter: CGPoint?
    
    static var storyboardInstance: HeroDetailsViewController {
        let storyboard = UIStoryboard(name: "Heroes", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "HeroDetailsViewController") as! HeroDetailsViewController
    }
    
    //MARK: - Action
    override func viewDidLoad() {
        super.viewDidLoad()
        view.bringSubviewToFront(heroImageView)
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        performPushAnimation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        performPopAnimation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if let child = additionalDetailsPageViewController {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
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
    
    //MARK: - Method
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
    
    //MARK: Animation
    func getSelectedCellFrameAndCenter() -> (frame: CGRect, center: CGPoint)?{
        guard let selectedCellFrame = heroListViewController?.getSelectedCellRect(),
            let selectedCellCenter = heroListViewController?.getSelectedCellCenter() else {
                return nil
        }
        return (selectedCellFrame, selectedCellCenter)
    }
    
    func computeFrameScale(dividend: CGRect, divisor: CGRect) -> (xScale: CGFloat, yScale: CGFloat){
        let xScale = dividend.width / divisor.width
        let yScale = dividend.height / divisor.height
        return (xScale, yScale)
    }
    
    func performPushAnimation() {
        
        if let selectedCellAttrs = getSelectedCellFrameAndCenter() {
            var selectedCellCenter = selectedCellAttrs.center
            for subview in view.subviews {
                if subview is UIImageView { continue }
                subview.transform = CGAffineTransform(translationX: 400, y: 0)
            }
            let errorOffset: CGFloat = 3 // Без него view дергается
            
            selectedCellCenter.y += errorOffset
            let originCenter = heroImageView.center
            let originFrame = heroImageView.frame
            
            let scales = computeFrameScale(dividend: selectedCellAttrs.frame, divisor: originFrame)
            
            heroImageView.center = selectedCellCenter
            heroImageView.transform = CGAffineTransform(scaleX: scales.xScale, y: scales.yScale)
            
            transitionCoordinator?.animateAlongsideTransition(in: view, animation: { [unowned self] context in
                self.heroImageView.center = originCenter
                for subview in self.view.subviews {
                    subview.transform = CGAffineTransform.identity
                }
            })
        }
    }
    
    func performPopAnimation() {
        
        if let selectedCellAttrs = getSelectedCellFrameAndCenter() {
            var selectedCellCenter = selectedCellAttrs.center
            let originFrame = heroImageView.frame
            
            let scales = computeFrameScale(dividend: selectedCellAttrs.frame, divisor: originFrame)
            
            let errorOffset: CGFloat = 2 // Без него view дергается
            selectedCellCenter.y += selectedCellAttrs.frame.height / 2 + errorOffset
            
            transitionCoordinator?.animateAlongsideTransition(in: view, animation: { [unowned self] context in
                self.heroImageView.center = selectedCellCenter
                for subview in self.view.subviews {
                    if subview is UIImageView {
                        subview.transform = CGAffineTransform(scaleX: scales.xScale, y: scales.yScale)
                        continue
                    }
                    subview.transform = CGAffineTransform(translationX: 400, y: 0)
                }
            })
        }
    }
    
}
