//
//  Character.swift
//  MarvelComics
//
//  Created by Kovalenko Ilia on 04/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import Foundation
import ObjectMapper

class Hero: Mappable {
    
    var id: Int?
    var name: String?
    var description: String?
    var thumbnail: MarverlImage?
    lazy var pathToImage: String? = {
        return thumbnail?.fullPath
    }()
    var comics: [Comic]?
    
    required init?(map: Map) {
        
    }
    
    init(by model: HeroCDObject) {
        id = Int(model.id)
        name = model.name
        description = model.heroDescription
        pathToImage = model.pathToImage
        if let modelComics = model.comics {
            comics = Array(modelComics) as? [Comic]
        }
    }
    
    func mapping(map: Map) {
        id          <- map["id"]
        name        <- map["name"]
        description <- map["description"]
        thumbnail   <- map["thumbnail"]
    }
}


