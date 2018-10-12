//
//  MarverlImage.swift
//  MarvelComics
//
//  Created by Kovalenko Ilia on 05/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import Foundation
import ObjectMapper

class MarverlImage: Mappable {
    
    var path: String?
    var imageExtension: String?
    lazy var fullPath: String? = {
        if let path = path, let imageExtension = imageExtension {
            return "\(path).\(imageExtension)"
        } else {
            return nil
        }
    }()
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        path            <- map["path"]
        imageExtension  <- map["extension"]
    }
}
