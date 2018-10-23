//
//  KeyChainService.swift
//  MarvelComics
//
//  Created by Kovalenko Ilia on 18/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//
//  https://github.com/dagostini/DAKeychain
//

import Foundation

class KeyChainService {
    
    private static let queue = DispatchQueue(label: "KeyChainQueue")
    
    let loggingEnabled = false
    
    private init() {}
    
    static var shared: KeyChainService = {
        return KeyChainService()
    }()
    
    subscript(key: String) -> String? {
        get {
            return load(with: key)
        } set {
            KeyChainService.queue.sync(flags: .barrier) {
                self.save(newValue, for: key)
            }
        }
    }
    
    private func save(_ string: String?, for key: String) {
        var query = keychainQuery(with: key)
        let objectData: Data? = string?.data(using: .utf8, allowLossyConversion: false)
        if SecItemCopyMatching(query as CFDictionary, nil) == noErr {
            if let dictData = objectData {
                let status = SecItemUpdate(query as CFDictionary, NSDictionary(dictionary: [kSecValueData: dictData]))
                logPrint("Update status: ", status)
            } else {
                let status = SecItemDelete(query as CFDictionary)
                logPrint("Delete status: ", status)
            }
        } else {
            if let dictData = objectData {
                query[kSecValueData as String] = dictData
                let status = SecItemAdd(query as CFDictionary, nil)
                logPrint("Update status: ", status)
            }
        }
    }
    
    private func load(with key: String) -> String? {
        var query = keychainQuery(with: key)
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard
            let resultsDict = result as? [String: Any],
            let resultsData = resultsDict[kSecValueData as String] as? Data,
            status == noErr else {
                logPrint("Load status: ", status)
                return nil
        }
        
        return String(data: resultsData, encoding: .utf8)
    }
    
    private func keychainQuery(with key: String) -> [String: Any] {
        let result: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                     kSecAttrService as String: key,
                                     kSecAttrAccessible as String: kSecAttrAccessibleAlwaysThisDeviceOnly]
        return result
    }
    
    private func logPrint(_ items: Any...) {
        if loggingEnabled {
            print(items)
        }
    }
    
}
