//
//  DataList.swift
//  MarvelComics
//
//  Created by Kovalenko Ilia on 05/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import Foundation
import ObjectMapper

class DataList<DataType: Mappable>: Mappable {
    
    var available: Int?
    var returned: Int?
    var collectionURI: String?
    var items: [DataType]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        available       <- map["available"]
        returned        <- map["returned"]
        collectionURI   <- map["collectionURI"]
        items           <- map["items"]
    }
    
}
