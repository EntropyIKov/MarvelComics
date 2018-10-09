//
//  ResponseCharacterDataWrapper.swift
//  MarvelComics
//
//  Created by Kovalenko Ilia on 04/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import Foundation
import ObjectMapper

class ResponseDataWrapper<DataType: Mappable>: Mappable {
    
    var responseStatusCode: Int?
    var statusDescription: String?
    var data: DataContainer<DataType>?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        responseStatusCode <- map["code"]
        statusDescription <- map["status"]
        data <- map["data"]
    }

}
