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
    var images: [MarverlImage]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id          <- map["id"]
        title       <- map["title"]
        description <- map["description"]
        format      <- map["format"]
        pageCount   <- map["pageCount"]
        thumbnail   <- map["thumbnail"]
        images      <- map["images"]
    }
}
