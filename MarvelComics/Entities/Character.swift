//
//  Character.swift
//  MarvelComics
//
//  Created by Kovalenko Ilia on 04/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import Foundation
import ObjectMapper

class Character: Mappable {
    
    var id: Int?
    var name: String?
    var description: String?
    var modified: Date?
    var resourceURI: String?
    var urls: [(type: String, url: String)]?
    var thumbnail: (path: String, `extension`: String)?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id          <- map["id"]
        name        <- map["name"]
        description <- map["description"]
        modified    <- map["modified"]
        resourceURI <- map["resourceURI"]
        urls        <- map["urls"]
        thumbnail   <- map["thumbnail"]
    }
}


