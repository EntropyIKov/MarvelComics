//
//  AdditionalDetailsTableViewController.swift
//  MarvelComics
//
//  Created by Kovalenko Ilia on 08/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import UIKit

class AdditionalDetailsTableViewController: UITableViewController {

    var heroId: Int!
    var entityType: RequestManager.EntityType!
    var nextPage = 0
    var data = [EntityWithTitleAndMarvelImageProtocol]()
    var canLoadNextData = true
    var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.alpha = 1.0
        activityIndicator.center = CGPoint(x: view.frame.width / 2, y: 140)
        view.addSubview(activityIndicator)
        getListOfObjects(from: nextPage)
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        refreshControl?.tintColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        if let refreshControl = refreshControl {
            tableView.addSubview(refreshControl)
        }
    }
    
    init(with heroId: Int, type entityType: RequestManager.EntityType) {
       super.init(nibName: nil, bundle: nil)
        self.heroId = heroId
        self.entityType = entityType
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        refreshListOfObjects()
    }
    
    func refreshListOfObjects() {
        if canLoadNextData {
            canLoadNextData = false
            nextPage = 0
            data.removeAll()
            tableView.reloadData()
            RequestManager.sharedInstance.getDetails(for: heroId, with: entityType, from: nextPage) { objects in
                self.data.insert(contentsOf: objects, at: self.data.count)
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
                self.nextPage += 1
                self.canLoadNextData = true
            }
        }
    }
    
    func getListOfObjects(from page: Int) {
        if canLoadNextData {
            canLoadNextData = false
            isWorkIndicator(isAnimated: true)
            RequestManager.sharedInstance.getDetails(for: heroId, with: entityType, from: page) { objects in
                self.data.insert(contentsOf: objects, at: self.data.count)
                self.tableView.reloadData()
                self.nextPage += 1
                self.canLoadNextData = true
                self.isWorkIndicator(isAnimated: false)
            }
        }
    }
    
    func isWorkIndicator(isAnimated: Bool) {
        if isAnimated && data.isEmpty {
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
        return data.count
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "defaultCell"
        if let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) {
            cell.textLabel?.text = data[indexPath.row].title
            if let fullPath = data[indexPath.row].thumbnail?.fullPath {
                let url = URL(string: fullPath)
                cell.imageView?.kf.setImage(with: url)
            }
            
            return cell
        } else {
            let cell = UITableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
            cell.textLabel?.text = data[indexPath.row].title
            if let fullPath = data[indexPath.row].thumbnail?.fullPath {
                let url = URL(string: fullPath)
                cell.imageView?.kf.setImage(with: url)
            }
            
            return cell
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let maxOffset = scrollView.contentSize.height - scrollView.frame.height
        let currentOffset = scrollView.contentOffset.y
        let maxScrollDiff: CGFloat = 100
        if maxOffset > 0, maxOffset - currentOffset < maxScrollDiff {
            getListOfObjects(from: nextPage)
        }
    }

}
