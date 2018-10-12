//
//  Series.swift
//  MarvelComics
//
//  Created by Kovalenko Ilia on 09/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import Foundation
import ObjectMapper

class Series: Mappable, EntityWithTitleAndMarvelImageProtocol {
    
    static var type = RequestManager.EntityType.series
    var id: Int?
    var title: String?
    var description: String?
    var thumbnail: MarverlImage?
    lazy var pathToImage: String? = {
        return thumbnail?.fullPath
    }()
    var heroes: [Hero]?
    
    required init?(map: Map) {}
    
    init(by model: SeriesCDObject) {
        id = Int(model.id)
        title = model.title
        description = model.seriesDescription
        pathToImage = model.pathToImage
        if let modelHeroes = model.heroes {
            heroes = Array(modelHeroes) as? [Hero]
        }
    }
    
    func mapping(map: Map) {
        id          <- map["id"]
        title       <- map["title"]
        description <- map["description"]
        thumbnail   <- map["thumbnail"]
    }
}
