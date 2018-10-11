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
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id          <- map["id"]
        name        <- map["name"]
        description <- map["description"]
        thumbnail   <- map["thumbnail"]
    }
    
    func saveHero() {
        
    }
    
    func deleteHero() {
        
    }
}


