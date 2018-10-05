//
//  RequestManager.swift
//  MarvelComics
//
//  Created by Kovalenko Ilia on 04/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import Foundation
import Alamofire
import SwiftHash

class RequestManager {
    
    static let sharedInstance = RequestManager()
    
    func getCharacters(page: Int, complection: @escaping ([Character]) -> (Void)) {
        
//        Alamofire.request(request,
//                          method: .get,
//                          parameters: parameters,
//                          headers: headers).responseJSON { responseJSON in
//            do {
//                debugPrint(responseJSON)
//                if let data = responseJSON.data {
//                    let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String: Any]
//                    if let jsonResult = jsonResult {
//                        let wrapper = ResponseDataWrapper<Character>.init(JSON: jsonResult)
//                        if let characters = wrapper?.data?.results {
//                            complection(characters)
//                        } else {
//                            print("Can't get characters")
//                        }
//                    }
//                }
//            } catch {
//                print("Oops... \(error)")
//            }
//        }
        doRequest(for: EntityType.Character, page: page) { responseJSON in
            do {
                debugPrint(responseJSON)
                if let data = responseJSON.data {
                    let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String: Any]
                    if let jsonResult = jsonResult {
                        let wrapper = ResponseDataWrapper<Character>.init(JSON: jsonResult)
                        debugPrint(wrapper)
                        if let characters = wrapper?.data?.results {
                            complection(characters)
                        } else {
                            print("Can't get characters")
                        }
                    }
                }
            } catch {
                print("Oops... \(error)")
            }
        }
    }
    
    private func doRequest(for entityType: EntityType, page: Int, complection: @escaping (DataResponse<Any>) -> ()) {
        let request: String
        switch entityType {
        case .Character:
            request = "\(Constants.apiEndPoint)\(Constants.pathToCharacters)"
        case .Comics:
            request = "\(Constants.apiEndPoint)\(Constants.pathToComics)"
        case .Story:
            request = "\(Constants.apiEndPoint)\(Constants.pathToStories)"
        case .Event:
            request = "\(Constants.apiEndPoint)\(Constants.pathToEvents)"
        case .Series:
            request = "\(Constants.apiEndPoint)\(Constants.pathToEvents)"
        }
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
        Alamofire.request(request,
                          method: .get,
                          parameters: parameters,
                          headers: headers).responseJSON(completionHandler: complection)
    }
    
    func getHash(with salt: String) -> String{
        let hash = MD5("\(salt)\(Constants.privateKey)\(Constants.publicKey)").lowercased()
        return hash
    }
    
    func getSalt() -> String{
        return "\(UInt64(Date().timeIntervalSince1970 * 1000))"
    }
    
}

extension RequestManager {
    private enum Constants {
        static let apiEndPoint      = "https://gateway.marvel.com"
        static let pathToCharacters = "/v1/public/characters"
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
    
    private enum EntityType {
        case Character
        case Comics
        case Story
        case Event
        case Series
    }
}
