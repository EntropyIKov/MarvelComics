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
    @IBOutlet weak var heroImageView: UIImageView!
    @IBOutlet weak var heroNameLabel: UILabel!
    
    //MARK: - Actions
    func populate(by hero: Hero) {
        if let pathToImage = hero.thumbnail?.fullPath {
            let url = URL(string: pathToImage)
            heroImageView.kf.setImage(with: url)
        } else {
            heroImageView.image = UIImage(named: "no_image")
        }
        
        heroImageView.layer.cornerRadius = heroImageView.frame.size.height / 2
        heroImageView.clipsToBounds = true
        heroNameLabel.text = hero.name
    }
    
}
