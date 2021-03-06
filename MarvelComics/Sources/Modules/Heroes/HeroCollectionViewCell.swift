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
    
    //MARK: - Outlet
    @IBOutlet private weak var heroImageView: UIImageView!
    @IBOutlet private weak var heroNameLabel: UILabel!
    
    //MARK: - Action
    func populate(by hero: Hero) {
        if let pathToImage = hero.pathToImage, let url = URL(string: pathToImage) {
            heroImageView.kf.indicatorType = .activity
            heroImageView.kf.setImage(with: url, completionHandler: { [weak self] (image, error, cacheType, imageUrl) in
                guard let _ = image else {
                    self?.heroImageView.image = UIImage(named: "no_image")
                    return
                }
            })
        } else {
            heroImageView.image = UIImage(named: "no_image")
        }
        
        heroImageView.layer.masksToBounds = false
        heroImageView.layer.cornerRadius = heroImageView.frame.height / 2
        heroImageView.clipsToBounds = true
        heroNameLabel.text = hero.name
    }
    
}

//MARK: - Support methods
extension HeroCollectionViewCell {
    func getImageViewCenter() -> CGPoint {
        return heroImageView.center
    }
    
    func getImageViewSize() -> CGSize {
        return heroImageView.frame.size
    }
    
    func hideImage(_ needHide: Bool) {
        heroImageView.isHidden = needHide
    }
}
