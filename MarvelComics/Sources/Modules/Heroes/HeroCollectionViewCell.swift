//
//  HeroCollectionViewCell.swift
//  MarvelComics
//
//  Created by Kovalenko Ilia on 08/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import UIKit
import Kingfisher

class HeroCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Outlets
    @IBOutlet private weak var heroImageView: UIImageView!
    @IBOutlet private weak var heroNameLabel: UILabel!
    
    //MARK: - Actions
    func populate(by hero: Hero) {
        if let pathToImage = hero.pathToImage, let url = URL(string: pathToImage) {
            let cacheKey = "\(pathToImage.hashValue)\(pathToImage)"
            let resource = ImageResource(downloadURL: url, cacheKey: cacheKey)
            heroImageView.kf.indicatorType = .activity
            heroImageView.kf.setImage(with: resource, completionHandler: { (image, error, cacheType, imageUrl) in
                if let image = image {
                    if !cacheType.cached {
                        ImageCache.default.store(image, original: nil, forKey: cacheKey, toDisk: true)
                    }
                }
            })
        } else {
            heroImageView.image = UIImage(named: "no_image")
        }
        heroImageView.clipsToBounds = true
        heroNameLabel.text = hero.name
    }
    
}
