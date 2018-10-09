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
    var id: Int?
    var title: String?
    var description: String?
    var thumbnail: MarverlImage?
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id          <- map["id"]
        title       <- map["title"]
        description <- map["description"]
        thumbnail   <- map["thumbnail"]
    }
}
