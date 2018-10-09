//
//  EntityWithTitleAndMarvelImageProtocol.swift
//  MarvelComics
//
//  Created by Kovalenko Ilia on 09/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import Foundation
import ObjectMapper

protocol EntityWithTitleAndMarvelImageProtocol {
    var title: String? { get set }
    var thumbnail: MarverlImage? { get set }
}
