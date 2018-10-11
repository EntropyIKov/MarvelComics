//
//  DataManager.swift
//  MarvelComics
//
//  Created by Kovalenko Ilia on 09/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//
//  https://www.youtube.com/watch?v=5ZUVCyOvZto
//

import Foundation

//public class DataManager {
//    
//    static fileprivate func getDocumentDirectory() -> URL {
//        if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
//            return url
//        } else {
//            fatalError("Unable to access document directory")
//        }
//    }
//    
//    static func save <T: Encodable> (_ objcet: T, wil fileName: String) {
//        let url = getDocumentDirectory().appendingPathComponent(fileName, isDirectory: false)
//        let encoder = JSONEncoder()
//        
//        do {
//            let data = try encoder.encode(objcet)
//            if FileManager.default.fileExists(atPath: url.path) {
//                try FileManager.default.removeItem(at: url)
//            }
//            FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
//        } catch {
//            fatalError(error.localizedDescription)
//        }
//    }
//    
//    static func load<T: Decodable>(_ fileName: String, with type: T) -> T {
//        
//    }
//    
//}
