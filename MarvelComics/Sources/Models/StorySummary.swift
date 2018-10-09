//
//  Story.swift
//  MarvelComics
//
//  Created by Kovalenko Ilia on 05/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import Foundation
import ObjectMapper

class StorySummary: SummaryProtocol, Mappable {
    
    var name: String?
    var resourceURI: String?
    var type: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        name        <- map["name"]
        resourceURI <- map["resourceURI"]
        type        <- map["type"]
    }
    
}
