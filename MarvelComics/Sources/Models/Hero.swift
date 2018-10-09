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
    var resourceURI: String?
    var urls: [(type: String, url: String)]?
    var thumbnail: MarverlImage?
    var comics: DataList<ComicsSummary>?
    var stories: DataList<StorySummary>?
    var events: DataList<EventSummary>?
    var series: DataList<SeriesSummary>?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id          <- map["id"]
        name        <- map["name"]
        description <- map["description"]
        resourceURI <- map["resourceURI"]
        urls        <- map["urls"]
        thumbnail   <- map["thumbnail"]
        comics      <- map["comics"]
        stories     <- map["stories"]
        events      <- map["events"]
        series      <- map["series"]
    }
}


