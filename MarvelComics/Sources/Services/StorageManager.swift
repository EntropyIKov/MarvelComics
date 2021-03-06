//
//  StorageManager.swift
//  MarvelComics
//
//  Created by Kovalenko Ilia on 11/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import Foundation
import CoreData

class StorageManager {
    static let sharedInstance = StorageManager()
    
    lazy var heroBackgroundContext: NSManagedObjectContext = {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()
    
    lazy var comicBackgroundContext: NSManagedObjectContext = {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()
    
    lazy var storyBackgroundContext: NSManagedObjectContext = {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()
    
    lazy var eventBackgroundContext: NSManagedObjectContext = {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()
    
    lazy var seriesBackgroundContext: NSManagedObjectContext = {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()
    
    lazy var backgroundContextArray: [NSManagedObjectContext] = {
        return [comicBackgroundContext, storyBackgroundContext, eventBackgroundContext, seriesBackgroundContext]
    }()
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Marvel_2_final")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        let context = container.viewContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        NotificationCenter.default.addObserver(context, selector: #selector(context.mergeChanges(fromContextDidSave:)), name: .NSManagedObjectContextDidSave, object: nil)
        return container
    }()
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                for obj in context.updatedObjects {
                    if obj.hasPersistentChangedValues {
                        try context.save()
                        NotificationCenter.default.post(name: .NSManagedObjectContextDidSave, object: self)
                        break
                    }
                }
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        
        for context in backgroundContextArray {
            if context.hasChanges {
                do {
                    try context.save()
                    NotificationCenter.default.post(name: .NSManagedObjectContextDidSave, object: self)
                } catch {
                    let nserror = error as NSError
                    print("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
        
        if heroBackgroundContext.hasChanges {
            do {
                try heroBackgroundContext.save()
                NotificationCenter.default.post(name: .NSManagedObjectContextDidSave, object: self)
            } catch {
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
