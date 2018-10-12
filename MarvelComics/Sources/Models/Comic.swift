//
//  Comic.swift
//  MarvelComics
//
//  Created by Kovalenko Ilia on 09/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import Foundation
import ObjectMapper

class Comic: Mappable, EntityWithTitleAndMarvelImageProtocol {    
    var id: Int?
    var title: String?
    var description: String?
    var format: String?
    var pageCount: Int?
    var thumbnail: MarverlImage?
    lazy var pathToImage: String? = {
        return thumbnail?.fullPath
    }()
    var heroes: [Hero]?
    static let type = RequestManager.EntityType.comic
    
    required init?(map: Map) {}
    
    init(by model: ComicCDObject) {
        id = Int(model.id)
        title = model.title
        description = model.comicDescription
        pathToImage = model.pathToImage
        format = model.format
        pageCount = Int(model.pageCount)
        if let modelHeroes = model.heroes {
            heroes = Array(modelHeroes) as? [Hero]
        }
    }
    
    func mapping(map: Map) {
        id          <- map["id"]
        title       <- map["title"]
        description <- map["description"]
        format      <- map["format"]
        pageCount   <- map["pageCount"]
        thumbnail   <- map["thumbnail"]
    }
}
