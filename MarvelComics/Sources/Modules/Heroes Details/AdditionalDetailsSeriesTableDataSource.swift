//
//  AdditionalDetailsSeriesTableDataSource.swift
//  MarvelComics
//
//  Created by Kovalenko Ilia on 18/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import UIKit
import Kingfisher
import CoreData

class AdditionalDetailsSeriesTableDataSource: NSObject, UITableViewDataSource {
    
    weak var fetchedResultsController: NSFetchedResultsController<SeriesCDObject>!
    weak var tableView: UITableView!
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let comics = fetchedResultsController.fetchedObjects else { return 0 }
        return comics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "cellWithImageAndLabel"
        let comicCDObject = fetchedResultsController.object(at: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        cell.isOpaque = false
        cell.textLabel?.isOpaque = false
        cell.textLabel?.text = comicCDObject.title
        if let pathToImage = comicCDObject.pathToImage, let url = URL(string: pathToImage) {
            cell.imageView?.kf.setImage(with: url)
        }
        
        return cell
    }
    
}

// NSFetchedResultsControllerDelegate
extension AdditionalDetailsSeriesTableDataSource: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
        case .delete:
            tableView.reloadData()
            //            if let indexPath = indexPath {
            //                tableView.deleteRows(at: [indexPath], with: .automatic)
        //            }
        case .update: break
        case .move: break
        }
    }
}
