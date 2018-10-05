//
//  NameCollectionViewCell.swift
//  MarvelComics
//
//  Created by Kovalenko Ilia on 05/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import UIKit

class NameCollectionViewCell: UICollectionViewCell {
   
    //MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    
    //MARK: - Actions
    func populate(by character: Character) {
        nameLabel.text = character.name
    }
    
}
