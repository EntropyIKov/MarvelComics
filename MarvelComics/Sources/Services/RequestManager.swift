//
//  RequestManager.swift
//  MarvelComics
//
//  Created by Kovalenko Ilia on 04/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import Foundation
import ObjectMapper
import Alamofire
import SwiftHash

class RequestManager {
    
    static let sharedInstance = RequestManager()
    
    func getHeroes(page: Int, complection: @escaping (DResult<Hero>) -> (Void)) {
        doRequest(for: EntityType.hero, page: page) { responseJSON in
            var result: DResult<Hero>
            do {
                
                guard let data = responseJSON.data else {
                    throw RequestManagerError.parsingError
                }
                
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as! [String: Any]
                let wrapper = ResponseDataWrapper<Hero>.init(JSON: jsonResult)
                
                guard let characters = wrapper?.data?.results else {
                    throw RequestManagerError.parsingError
                }
                
                result = .success(characters)
                
            } catch {
                result = .failure(error)
            }
            complection(result)
        }
    }
    
    func getComicsDetails(for heroId: Int, from page: Int, complection: @escaping (DResult<Comic>) -> (Void)) {
        let request = "\(Constants.apiEndPoint)\(Constants.pathToHeroes)/\(heroId)/\(EntityType.comic.rawValue)"
        getDetails(for: heroId, from: page, with: request, complection: complection)
    }
    
    func getStoriesDetails(for heroId: Int, from page: Int, complection: @escaping (DResult<Story>) -> (Void)) {
        let request = "\(Constants.apiEndPoint)\(Constants.pathToHeroes)/\(heroId)/\(EntityType.story.rawValue)"
        getDetails(for: heroId, from: page, with: request, complection: complection)
    }
    
    func getEventsDetails(for heroId: Int, from page: Int, complection: @escaping (DResult<Event>) -> (Void)) {
        let request = "\(Constants.apiEndPoint)\(Constants.pathToHeroes)/\(heroId)/\(EntityType.event.rawValue)"
        getDetails(for: heroId, from: page, with: request, complection: complection)
    }
    
    func getSeriesDetails(for heroId: Int, from page: Int, complection: @escaping (DResult<Series>) -> (Void)) {
        let request = "\(Constants.apiEndPoint)\(Constants.pathToHeroes)/\(heroId)/\(EntityType.series.rawValue)"
        getDetails(for: heroId, from: page, with: request, complection: complection)
    }
    
    private func getDetails<Type: EntityWithTitleAndMarvelImageProtocol>(for heroId: Int, from page: Int, with link: String, complection: @escaping (DResult<Type>) -> (Void)) {
        let requestParameters = makeRequestParams(with: page)
        Alamofire.request(link,
                          method: .get,
                          parameters: requestParameters.parameters,
                          headers: requestParameters.headers).responseJSON { responseJSON in
                            let result: DResult<Type>
                            do {
                                guard let data = responseJSON.data else {
                                    throw RequestManagerError.parsingError
                                }
                                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as! [String: Any]
                                let wrapper = ResponseDataWrapper<Type>.init(JSON: jsonResult)
                                
                                guard let objects = wrapper?.data?.results else {
                                    throw RequestManagerError.parsingError
                                }
                                
                                result = .success(objects)
                                
                            } catch {
                                result = DResult.failure(error)
                            }
                            complection(result)
        }
    }
    
    private func doRequest(for entityType: EntityType, page: Int, complection: @escaping (DataResponse<Any>) -> ()) {
        let request: String
        switch entityType {
        case .hero:
            request = "\(Constants.apiEndPoint)\(Constants.pathToHeroes)"
        case .comic:
            request = "\(Constants.apiEndPoint)\(Constants.pathToComics)"
        case .story:
            request = "\(Constants.apiEndPoint)\(Constants.pathToStories)"
        case .event:
            request = "\(Constants.apiEndPoint)\(Constants.pathToEvents)"
        case .series:
            request = "\(Constants.apiEndPoint)\(Constants.pathToEvents)"
        }
        let requestParameters = makeRequestParams(with: page)
        Alamofire.request(request,
                          method: .get,
                          parameters: requestParameters.parameters,
                          headers: requestParameters.headers).responseJSON(completionHandler: complection)
    }
    
    func getHash(with salt: String) -> String{
        let hash = MD5("\(salt)\(Constants.privateKey)\(Constants.publicKey)").lowercased()
        return hash
    }
    
    func getSalt() -> String{
        return "\(UInt64(Date().timeIntervalSince1970 * 1000))"
    }
    
    private func makeRequestParams(with page: Int) -> (parameters: Parameters, headers: HTTPHeaders) {
        let salt = getSalt()
        let parameters: Parameters = [
            RequestParamName.salt: salt,
            RequestParamName.publicKey: Constants.publicKey,
            RequestParamName.hash: getHash(with: salt),
            RequestParamName.limit: Constants.limit,
            RequestParamName.offset: Constants.limit * page
        ]
        let headers: HTTPHeaders = [
            "Accept": "*/*"
        ]
        return (parameters, headers)
    }
    
}

extension RequestManager {
    private enum Constants {
        static let apiEndPoint      = "https://gateway.marvel.com"
        static let pathToHeroes = "/v1/public/characters"
        static let pathToComics     = "/v1/public/comics"
        static let pathToEvents     = "/v1/public/events"
        static let pathToSeries     = "/v1/public/series"
        static let pathToStories    = "/v1/public/stories"
        static let privateKey       = "4c90a84675c7471745f0bfcfc4bde57aed0ebb25"
        static let publicKey        = "0940fb6dba2c551b623c38d678417d25"
        static let limit = 20
        
    }
    
    private enum RequestParamName {
        static let salt = "ts"
        static let publicKey = "apikey"
        static let hash = "hash"
        static let offset = "offset"
        static let limit = "limit"
    }
    
    enum EntityType: String {
        case hero = "characters"
        case comic = "comics"
        case story = "stories"
        case event = "events"
        case series = "series"
    }
}

enum DResult<ValueType> {
    case success([ValueType])
    case failure(Error)
}

enum RequestManagerError: Error {
    case parsingError
}
