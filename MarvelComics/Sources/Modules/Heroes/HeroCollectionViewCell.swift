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
            
            heroImageView.kf.indicatorType = .activity
            ImageCache.default.retrieveImage(forKey: cacheKey, options: nil) { [weak self] image, cacheType in
                if let image = image {
                    self?.heroImageView.image = image
                } else {
                    let resource = ImageResource(downloadURL: url, cacheKey: cacheKey)
                    self?.heroImageView.kf.setImage(with: resource) {
                        (image, error, cacheType, imageUrl) in
                        if let image = image, cacheType == .none{
                            ImageCache.default.store(image, forKey: cacheKey, toDisk: true)
                        }
                    }
                }
            }
        } else {
            heroImageView.image = UIImage(named: "no_image")
        }
        heroImageView.layer.masksToBounds = false
        heroImageView.layer.cornerRadius = heroImageView.frame.height / 2
        heroImageView.clipsToBounds = true
        heroNameLabel.text = hero.name
    }
    
}
