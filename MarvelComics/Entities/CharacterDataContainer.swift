//
//  CharacterDataContainer.swift
//  MarvelComics
//
//  Created by Kovalenko Ilia on 04/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import Foundation
import ObjectMapper

class CharacterDataContainer: Mappable {
   
    var offset: Int?
    var limit: Int?
    var total: Int?
    var count: Int?
    var results: [Character]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        offset  <- map["offset"]
        limit   <- map["limit"]
        total   <- map["total"]
        count   <- map["count"]
        results <- map["results"]
    }
}
